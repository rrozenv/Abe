
import Foundation
import UIKit
import RxSwift
import RxCocoa
import Gifu

final class ImageSearchViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: ImageSearchViewModel!
    private let dataSource = ImageSearchDataSource()
    
    private var backButton: UIButton!
    private var searchBarView: SearchBarView!
    private var collectionView: UICollectionView!
    private var collectionViewGridLayout: UICollectionViewFlowLayout!

    private var searchOffsetCount = 0
    private var returnedResultsCount = 25
  
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupBackButton()
        setupSearchBarView()
        setupCollectionView()
        bindViewModel()
    }
    
    deinit { print("Search Controller deinit") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func bindViewModel() {
        
        //MARK: - Inputs
        searchBarView.searchTextField.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.searchText)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(to: viewModel.inputs.backButtonTappedInput)
            .disposed(by: disposeBag)
        
        //MARK: - Outputs
        viewModel.outputs.fetchedImages
            .drive(onNext: { [weak self] images in
                self?.searchOffsetCount += images.count
                self?.dataSource.load(images: images)
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.paginatedImages
            .drive(onNext: { [weak self] in
                self?.searchOffsetCount += $0.count
                self?.dataSource.loadPaginated(images: $0)
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        searchBarView.clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.searchBarView.searchTextField.text = nil
                self?.searchBarView.clearButton.isHidden = true
                self?.dataSource.load(images: [])
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isClearSearchButtonHidden
            .drive(searchBarView.clearButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorTracker
            .drive(onNext: { (error) in
                print("ERRROR")
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
}


extension ImageSearchViewController {
    
    private func setupSearchBarView() {
        searchBarView = SearchBarView()
        searchBarView.style(placeHolder: "Search GIFS...", backColor: Palette.faintGrey.color, searchIcon: #imageLiteral(resourceName: "IC_CheckMark"), clearIcon: #imageLiteral(resourceName: "IC_RedCancelCircle"))
        
        view.addSubview(searchBarView)
        searchBarView.snp.makeConstraints { (make) in
            make.width.equalTo(view).multipliedBy(0.84)
            make.height.equalTo(view).multipliedBy(0.07)
            make.centerX.equalTo(view)
            make.top.equalTo(backButton.snp.bottom).offset(10)
        }
    }
    
    private func setupBackButton() {
        backButton = UIButton.backButton(image: #imageLiteral(resourceName: "IC_BackArrow_Black"))
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            if #available(iOS 11.0, *) {
                if UIDevice.iPhoneX {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-44)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-20)
                }
            } else {
                make.top.equalTo(view.snp.top)
            }
        }
    }
    
}

extension ImageSearchViewController {
    
    fileprivate func setupCollectionView() {
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: ImageSearchCollectionViewLayout(topInset: 0))
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self.dataSource
        collectionView.register(ImageSearchCollectionCell.self, forCellWithReuseIdentifier: ImageSearchCollectionCell.defaultReusableId)
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBarView.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(view)
        }
    }
    
}

extension ImageSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard dataSource.shouldLoadMoreResults(indexPath) else { return }
        viewModel.inputs.fetchImagesOffsetInput.onNext(searchOffsetCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       guard let cell = collectionView.cellForItem(at: indexPath) as? ImageSearchCollectionCell else { return }
       cell.endAnimation()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = self.dataSource.imageAtIndexPath(indexPath) else { return }
        viewModel.inputs.didSelectImage.onNext(image)
    }
    
}
