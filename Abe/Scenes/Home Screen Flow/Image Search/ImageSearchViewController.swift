
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ImageSearchViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: ImageSearchViewModel!
    let dataSource = ImageSearchDataSource()
    var searchTextField: UITextField!
    var searchIcon: UIImageView!
    var clearSearchButton: UIButton!
    
    fileprivate var currentPage = 1
    fileprivate var latestSearchText = ""
    fileprivate var shouldShowLoadingCell = false
    var collectionView: UICollectionView!
    var collectionViewGridLayout: UICollectionViewFlowLayout!
  
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupSearchTextfield()
        setupSearchTextFieldConstraints()
        setupClearSearchButton()
        setupCollectionView()
        bindViewModel()
    }
    
    deinit {
        print("Search Controller deinit")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        searchTextField.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { (text) in
                self.viewModel.inputs.searchText.onNext(text)
            })
            //.bind(to: viewModel.inputs.searchText)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.fetchedImages.drive(onNext: { [weak self] images in
            print("IMAGES \(images.count)")
            self?.dataSource.load(images: images)
            self?.collectionView.reloadData()
        })
        .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { (error) in
                print("ERRROR")
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.selectedImage
            .drive(onNext: { (image) in
                print("Selected image with url: \(image.webformatURL)")
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: Output
    
    func fetchNextPage() {
        currentPage += 1
        //createRequestWithSearch(query: latestSearchText)
    }
    
//    func createRequestWithSearch(query: String) {
//        latestSearchText = query
//        let request = GIFSearch.Request(query: query, page: currentPage)
//        engine?.makeQuery(request: request)
//    }
    
//    fileprivate func shouldDisplayClearSearchButton(_ searchText: String) {
//        guard !searchText.isEmpty && searchText != "" else {
//            clearSearchButton.isHidden = true
//            return
//        }
//        clearSearchButton.isHidden = false
//    }
    
//    func didTapClearSearch(_ sender: UIButton) {
//        self.searchTextField.text = nil
//        self.shouldDisplayClearSearchButton("")
//        self.displayedGIFS = [Imageable]()
//        self.collectionView.reloadData()
//    }
    
    //MARK: Input
    

}


extension ImageSearchViewController {
    
    fileprivate func setupSearchTextfield() {
        searchTextField = UITextField()
        searchTextField.placeholder = "Search Images..."
        searchTextField.backgroundColor = UIColor.red
        searchTextField.layer.cornerRadius = 4.0
        searchTextField.layer.masksToBounds = true
        searchTextField.font = FontBook.AvenirMedium.of(size: 14)
        searchTextField.textColor = UIColor.black
    }
    
    fileprivate func setupSearchTextFieldConstraints() {
        self.view.addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 65).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        searchTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.11).isActive = true
    }
    
    fileprivate func setupSearchIcon() {
        searchIcon = UIImageView(image: #imageLiteral(resourceName: "IC_Search"))
        
        self.view.addSubview(searchIcon)
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.widthAnchor.constraint(equalToConstant: Screen.width * 0.048).isActive = true
        searchIcon.heightAnchor.constraint(equalToConstant: Screen.width * 0.048).isActive = true
        searchIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        searchIcon.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor, constant: -2).isActive = true
    }
    
    fileprivate func setupClearSearchButton() {
        clearSearchButton = UIButton()
        clearSearchButton.backgroundColor = UIColor.brown
        clearSearchButton.isHidden = true
        
        self.view.addSubview(clearSearchButton)
        clearSearchButton.translatesAutoresizingMaskIntoConstraints = false
        clearSearchButton.widthAnchor.constraint(equalToConstant: Screen.width * 0.064).isActive = true
        clearSearchButton.heightAnchor.constraint(equalToConstant: Screen.width * 0.064).isActive = true
        clearSearchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        clearSearchButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor).isActive = true
    }
    
}

extension ImageSearchViewController {
    
    fileprivate func setupCollectionView() {
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: ImageSearchCollectionViewLayout(topInset: 20))
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self.dataSource
        collectionView.register(ImageSearchCollectionCell.self, forCellWithReuseIdentifier: ImageSearchCollectionCell.defaultReusableId)
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(searchTextField.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
    }
    
}

extension ImageSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard shouldLoadMoreResults(indexPath) else { return }
        fetchNextPage()
    }
    
    func shouldLoadMoreResults(_ indexPath: IndexPath) -> Bool {
        guard shouldShowLoadingCell else { return false }
        return true
        //return indexPath.item == self.displayedGIFS.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = self.dataSource.imageAtIndexPath(indexPath) else { return }
        viewModel.inputs.didSelectImage.onNext(image)
    }
    
}
