//
//  PhotoListViewModel.swift
//  MVVM
//
//  Created by 이동건 on 29/06/2018.
//  Copyright © 2018 이동건. All rights reserved.
//

import Foundation

class PhotoListViewModel {
    //MARK: Properties
    let apiService: APIServiceProtocol
    private var photos: [Photo] = [Photo]()
    //MARK: Binding Closures
    var reloadTableViewClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var showAlertClosure: (()->())?
    
    private var cellViewModels:[PhotoListCellViewModel] = [PhotoListCellViewModel]() {
        didSet{
            self.reloadTableViewClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var isLoading: Bool = false {
        didSet{
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    //MARK: Initializer
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    //MARK: Methods
    func requestFetchData(){
        self.isLoading = true
        apiService.fetchPopularPhoto { [weak self] (success, photos, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.processFetchedPhoto(photos: photos)
            }
        }
    }
    
    private func processFetchedPhoto( photos: [Photo] ) {
        self.photos = photos // Cache
        var vms = [PhotoListCellViewModel]()
        for photo in photos {
            vms.append( createCellViewModel(photo: photo) )
        }
        self.cellViewModels = vms
    }
    
    func createCellViewModel( photo: Photo ) -> PhotoListCellViewModel {
        
        //Wrap a description
        var descTextContainer: [String] = [String]()
        if let camera = photo.camera {
            descTextContainer.append(camera)
        }
        if let description = photo.description {
            descTextContainer.append( description )
        }
        let desc = descTextContainer.joined(separator: " - ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return PhotoListCellViewModel( titleText: photo.name,
                                       descText: desc,
                                       imageUrl: photo.image_url,
                                       dateText: dateFormatter.string(from: photo.created_at) )
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> PhotoListCellViewModel {
        return cellViewModels[indexPath.row]
    }
}

