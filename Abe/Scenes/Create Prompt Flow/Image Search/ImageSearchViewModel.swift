
import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol ImageSearchViewModelInputs {
    var searchText: AnyObserver<String> { get }
    var didSelectImage: AnyObserver<ImageRepresentable> { get }
}

protocol ImageSearchViewModelOutputs {
    var fetchedImages: Driver<[ImageRepresentable]> { get }
    var selectedImage: Driver<ImageRepresentable> { get }
    var activityIndicator: Driver<Bool> { get }
    var errorTracker: Driver<Error> { get }
    var dismissViewController: Observable<Void> { get }
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
    let didSelectImage: AnyObserver<ImageRepresentable>
    
//MARK: - Outputs
    var outputs: ImageSearchViewModelOutputs { return self }
    let fetchedImages: Driver<[ImageRepresentable]>
    let selectedImage: Driver<ImageRepresentable>
    let activityIndicator: Driver<Bool>
    let errorTracker: Driver<Error>
    let dismissViewController: Observable<Void>

//MARK: - Init
    init(imageService: ImageService<GifAPI> = ImageService<GifAPI>(),
         router: ImageSearchRoutingLogic) {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        self.activityIndicator = activityIndicator.asDriver()
        self.errorTracker = errorTracker.asDriver()
       
//MARK: - Fetch Images
        let _searchText = PublishSubject<String>()
        self.searchText = _searchText.asObserver()
        let searchTextObservable = _searchText.asObservable()
        
        self.fetchedImages = searchTextObservable
            .flatMapLatest {
                imageService.fetchGIFS(query: $0)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .replaceNilWith([])
            .asDriver(onErrorJustReturn: [])
        
 //MARK: - Selected Image
        let _didSelectImage = PublishSubject<ImageRepresentable>()
        self.didSelectImage = _didSelectImage.asObserver()
        let selectedImageObservable = _didSelectImage.asObservable()
        //Passes value to create prompt vc
        self.selectedImage = selectedImageObservable.asDriverOnErrorJustComplete()
        
        self.dismissViewController = selectedImageObservable
            .mapToVoid()
            .do(onNext: router.toMainCreateReplyInput)
    }
    
}

