
import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol ImageSearchViewModelInputs {
    var searchText: AnyObserver<String> { get }
    var didSelectImage: AnyObserver<ImageRepresentable> { get }
    var backButtonTappedInput: AnyObserver<Void> { get }
    var fetchImagesOffsetInput: AnyObserver<Int> { get }
}

protocol ImageSearchViewModelOutputs {
    var fetchedImages: Driver<[ImageRepresentable]> { get }
    var paginatedImages: Driver<[ImageRepresentable]> { get }
    var selectedImage: Driver<ImageRepresentable> { get }
    var activityIndicator: Driver<Bool> { get }
    var errorTracker: Driver<Error> { get }
    var isClearSearchButtonHidden: Driver<Bool> { get }
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
    let backButtonTappedInput: AnyObserver<Void>
    let fetchImagesOffsetInput: AnyObserver<Int>
    
//MARK: - Outputs
    var outputs: ImageSearchViewModelOutputs { return self }
    let fetchedImages: Driver<[ImageRepresentable]>
    let paginatedImages: Driver<[ImageRepresentable]>
    let selectedImage: Driver<ImageRepresentable>
    let activityIndicator: Driver<Bool>
    let errorTracker: Driver<Error>
    let isClearSearchButtonHidden: Driver<Bool>
    
//MARK: - Init
    init(imageService: ImageService<GifAPI> = ImageService<GifAPI>(),
         router: ImageSearchRoutingLogic) {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        self.activityIndicator = activityIndicator.asDriver()
        self.errorTracker = errorTracker.asDriver()
       
//MARK: - Subjects
        let _searchText = PublishSubject<String>()
        let _didSelectImage = PublishSubject<ImageRepresentable>()
        let _backButtonTappedInput = PublishSubject<Void>()
        let _fetchImagesOffsetInput = PublishSubject<Int>()

//MARK: - Observers
        self.searchText = _searchText.asObserver()
        self.didSelectImage = _didSelectImage.asObserver()
        self.backButtonTappedInput = _backButtonTappedInput.asObserver()
        self.fetchImagesOffsetInput = _fetchImagesOffsetInput.asObserver()
        
//MARK: - Observables
        let searchTextObservable = _searchText.asObservable().startWith("")
        let selectedImageObservable = _didSelectImage.asObservable()
        let backButtonTappedObservable = _backButtonTappedInput.asObservable()
        let fetchImagesOffsetObservable = _fetchImagesOffsetInput.asObservable()

//MARK: - Outputs
        self.fetchedImages = searchTextObservable
            .flatMapLatest {
                imageService.fetchGIFS(query: $0, offset: 0)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .replaceNilWith([])
            .asDriver(onErrorJustReturn: [])
        
        self.paginatedImages = fetchImagesOffsetObservable
            .withLatestFrom(searchTextObservable, resultSelector: { (searchText: $1, offset: $0) })
            .flatMapLatest {
                imageService.fetchGIFS(query: $0.searchText, offset: $0.offset)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .replaceNilWith([])
            .asDriver(onErrorJustReturn: [])
        
        //Passes value to create prompt vc
        self.selectedImage = selectedImageObservable.asDriverOnErrorJustComplete()
        
        self.isClearSearchButtonHidden = searchTextObservable
            .map { $0.isEmpty && $0 == "" }
            .asDriver(onErrorJustReturn: false)

//MARK: - Routing
        Observable.of(selectedImageObservable.mapToVoid(), backButtonTappedObservable)
            .merge()
            .do(onNext: router.toMainCreateReplyInput)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

