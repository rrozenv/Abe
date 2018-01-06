
import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

//protocol ReplyCellViewModelInputs {
//    /// Call to configure cell with activity value.
//    var reply: PublishSubject<PromptReply> { get }
//}
//
//protocol ReplyCellViewModelOutputs {
//    /// Emits the backer image url to be displayed.
//    var body: Driver<String> { get }
//}
//
//protocol ReplyCellViewModelType {
//    var inputs: ReplyCellViewModelInputs { get }
//    var outputs: ReplyCellViewModelOutputs { get }
//}

public final class ReplyCellViewModel {
    
    struct Input {
        let reply: PublishSubject<PromptReply>
    }
    
    struct Output {
        let body: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let body = input.reply
            .map { $0.body }
            .asDriver(onErrorJustReturn: "")
        
        return Output(body: body)
    }
    
}

final class ReplyTableCell: UITableViewCell, ValueCell {

    typealias Value = PromptReply
    static var defaultReusableId: String = "ReplyTableCell"
    private(set) var disposeBag = DisposeBag()
    fileprivate let viewModel = ReplyCellViewModel()
    
    // MARK: - Properties
    fileprivate var containerView: UIView!
    fileprivate var replyBodyLabel: UILabel!
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupContainerView()
        setupTitleLabel()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
    }
    
    func configureWith(value: PromptReply) {
        let inputs = ReplyCellViewModel
            .Input(reply: PublishSubject<PromptReply>())
        inputs.reply.onNext(value)
        
        let outputs = viewModel.transform(input: inputs)
        
        outputs.body
            .drive(replyBodyLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.height.equalTo(100)
        }
    }
    
    private func setupTitleLabel() {
        replyBodyLabel = UILabel()
        
        containerView.addSubview(replyBodyLabel)
        replyBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        replyBodyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(containerView.snp.center)
        }
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
}
