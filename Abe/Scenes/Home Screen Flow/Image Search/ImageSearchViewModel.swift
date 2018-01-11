
import Foundation
import RxSwift
import RxCocoa

protocol ImageSearchViewModelInputs {
    var searchText: AnyObserver<String> { get }
    var didSelectImage: AnyObserver<PixaImage> { get }
}

protocol ImageSearchViewModelOutputs {
    var fetchedImages: Driver<[PixaImage]> { get }
    var selectedImage: Driver<PixaImage> { get }
    var activityIndicator: Driver<Bool> { get }
    var errorTracker: Driver<Error> { get }
}

protocol ImageSearchViewModelType {
    var inputs: ImageSearchViewModelInputs { get }
    var outputs: ImageSearchViewModelOutputs { get }
}

final class ImageSearchViewModel: ImageSearchViewModelType, ImageSearchViewModelInputs, ImageSearchViewModelOutputs {

    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: ImageSearchViewModelInputs { return self }
    let searchText: AnyObserver<String>
    let didSelectImage: AnyObserver<PixaImage>
    
    //MARK: - Outputs
    var outputs: ImageSearchViewModelOutputs { return self }
    let fetchedImages: Driver<[PixaImage]>
    let selectedImage: Driver<PixaImage>
    let activityIndicator: Driver<Bool>
    let errorTracker: Driver<Error>
    
    init(imageService: PixaImageService = PixaImageService(),
         router: ImageSearchRoutingLogic) {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        self.activityIndicator = activityIndicator.asDriver()
        self.errorTracker = errorTracker.asDriver()
       
        let _searchText = PublishSubject<String>()
        self.searchText = _searchText.asObserver()
        let searchTextObservable = _searchText.asObservable()
        
        let _didSelectImage = PublishSubject<PixaImage>()
        self.didSelectImage = _didSelectImage.asObserver()
        let selectedImageObservable = _didSelectImage.asObservable()
        
        self.fetchedImages = searchTextObservable
            .flatMapLatest {
                imageService.fetchImages(query: $0, page: 1)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: [])
            .startWith([])
        
        self.selectedImage = selectedImageObservable
            .debug()
            .map { $0 }
            .asDriverOnErrorJustComplete()
    }
    
}

