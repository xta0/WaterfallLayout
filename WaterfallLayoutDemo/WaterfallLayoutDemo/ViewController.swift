//
//  ViewController.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/13/25.
//

import UIKit

/**
 UI:
 1. Header and footer views
 2. Click and drag & drop
 
 Data:
 1. Image cache
 2. HTTP data cache
 3. Decoding large images
 */

class ViewController: UIViewController {
    enum Layout {
        case grid
        case waterfall
    }
    
    static let searchBarHeight = 60.0
    static let padding = 8.0
    
    private(set) var query: String = ""
    private(set) var layout: Layout = .grid
    
    lazy var searchBar: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = .white
        let textField = UITextField()
        textField.tag = 1
        textField.placeholder = "Search..."
        textField.delegate = self
        textField.borderStyle = .roundedRect
        view.addSubview(textField)
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.gridLayout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var pullToRefreshView: UIRefreshControl = {
        let pullToRefresh = UIRefreshControl()
        pullToRefresh.addTarget(self, action: #selector(reload), for: .valueChanged)
        return pullToRefresh
    }()
    
    lazy var gridLayout: UICollectionViewFlowLayout = {
        let gridLayout = UICollectionViewFlowLayout()
        gridLayout.minimumInteritemSpacing = 0
        gridLayout.minimumLineSpacing = 0
        gridLayout.sectionInset = .zero
        return gridLayout
    }()
    
    lazy var waterfallLayout: WaterfallLayout = {
        let waterfallLayout = WaterfallLayout()
        waterfallLayout.delegate = self
        return waterfallLayout
    }()
    
    let model = UnsplashModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "WaterfallLayoutDemo"
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.collectionView)
        self.collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        self.collectionView.refreshControl = self.pullToRefreshView
        
        // add a button to the right navigation bar button item
        let rightButton = UIBarButtonItem(title: "WaterFall", style: .plain, target: self, action: #selector(changeLayout))
        navigationItem.rightBarButtonItem = rightButton
        self.fetchPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Get safe area insets after the view layout cycle
        let insets = self.view.safeAreaInsets
        let contentFrame = CGRect(
            x: insets.left,
            y: insets.top,
            width: view.frame.width - insets.left - insets.right,
            height: view.frame.height - insets.top - insets.bottom
        )
        
        // Update searchBar frame
        searchBar.frame = CGRect(
            x: contentFrame.origin.x,
            y: contentFrame.origin.y,
            width: contentFrame.size.width,
            height: Self.searchBarHeight
        )
        let textField = searchBar.viewWithTag(1)
        textField?.frame = CGRectInset(searchBar.bounds, 10, 10)
        
        // Update collectionView frame
        collectionView.frame = CGRect(
            x: contentFrame.origin.x,
            y: contentFrame.origin.y + Self.searchBarHeight,
            width: contentFrame.size.width,
            height: contentFrame.size.height - Self.searchBarHeight
        )
    }
    
    private func fetchPhotos() {
        // Do any additional setup after loading the view.
        Task { [weak self] in
            guard let strongSelf = self else { return }
            await strongSelf.model.fetchPhotos()
            strongSelf.collectionView.reloadData()
            strongSelf.pullToRefreshView.endRefreshing()
        }
    }
    
    private func searchPhotos(_ keyword: String) {
        // start a spinner
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.frame = self.searchBar.bounds
        spinner.startAnimating()
        self.searchBar.addSubview(spinner)
        Task { [weak self] in
            guard let strongSelf = self else { return }
            await strongSelf.model.fetchPhotos(keyword)
            spinner.removeFromSuperview()
            strongSelf.pullToRefreshView.endRefreshing()
            strongSelf.collectionView.reloadData()
        }
    }
    
    @objc private func reload() {
        Task { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.model.reset()
            strongSelf.collectionView.reloadData()
        }
        if self.query.isEmpty {
            self.fetchPhotos()
        } else {
            self.searchPhotos(self.query)
        }
    }
    
    @objc private func changeLayout() {
        guard let button = navigationItem.rightBarButtonItem else {
            return
        }
        // change the colleciton view layout
        if self.layout == .grid {
            self.collectionView.setCollectionViewLayout(self.waterfallLayout, animated: true)
            self.layout = .waterfall
            button.title = "Grid"
        } else {
            self.collectionView.setCollectionViewLayout(self.gridLayout, animated: true)
            self.layout = .grid
            button.title = "WaterFall"
        }
        // Scroll to the first item
        if self.collectionView.numberOfSections > 0 && self.collectionView.numberOfItems(inSection: 0) > 0 {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.model.photos.isEmpty {
            return 0
        }
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.model.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath)
        let index = indexPath.item
        if let photoCell = cell as? PhotoCell, index < self.model.photos.count {
            photoCell.setPhoto(self.model.photos[indexPath.item])
            return photoCell
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == self.model.photos.count - 1 {
            if self.query.isEmpty {
                self.fetchPhotos()
            } else {
                self.searchPhotos(self.query)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width / 3
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let keyword = textField.text ?? ""
        self.query = keyword
        self.reload()
        return true
    }
}

extension ViewController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, photoSizeForItemAt indexPath: IndexPath) -> CGSize {
        let photo = self.model.photos[indexPath.item]
        return CGSize(width: photo.width, height: photo.height)
    }
}


