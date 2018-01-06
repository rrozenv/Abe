
import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol ReplyCellViewModelInputs {
    /// Call to configure cell with activity value.
    var reply: PublishSubject<PromptReply> { get }
}

protocol ReplyCellViewModelOutputs {
    /// Emits the backer image url to be displayed.
    var body: Driver<String> { get }
}

protocol ReplyCellViewModelType {
    var inputs: ReplyCellViewModelInputs { get }
    var outputs: ReplyCellViewModelOutputs { get }
}

public final class ReplyCellViewModel: ReplyCellViewModelInputs,
ReplyCellViewModelOutputs, ReplyCellViewModelType {
    
    var inputs: ReplyCellViewModelInputs { return self }
    let reply = PublishSubject<PromptReply>()
    
    var outputs: ReplyCellViewModelOutputs { return self }
    let body: Driver<String>

    public init() {
        self.body = self.reply
            .asObservable()
            .map { $0.body }
            .asDriver(onErrorJustReturn: "")
    }
    
}

final class ReplyTableCell: UITableViewCell, ValueCell {

    typealias Value = PromptReply
    static var defaultReusableId: String = "ReplyTableCell"
    private(set) var disposeBag = DisposeBag()
    fileprivate let viewModel = ReplyCellViewModel()
    
    // MARK: - Properties
    fileprivate var replyBodyLabel: UILabel!
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.outputs
            .body
            .drive(replyBodyLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func configureWith(value: PromptReply) {
        viewModel.inputs.reply.onNext(value)
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
}
