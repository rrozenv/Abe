
import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol SettingsDelegate: class {
    func closeSettings()
}

class SettingsViewController: UIViewController, BindableType {
    
    let disposeBag = DisposeBag()
    let dataSource = SettingsDataSource()
    var viewModel: SettingsViewModel!
    private var opaqueButton: UIButton!
    private var tableBackgroundView: UIView!
    private var tableView: UITableView!
    private var tableViewHeightConstraint: Constraint!
    weak var delegate: SettingsDelegate?
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.clear
        setupTableView()
        setupTableBackgroundView()
        setupOpaqueButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit { print("rate reply deinit") }
    
    func bindViewModel() {
        //MARK: - Input
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .distinctUntilChanged()
            .map { [weak self] in self?.dataSource.settingAtIndexPath($0) }.unwrap()
            .bind(to: viewModel.inputs.selectedSettingInput)
            .disposed(by: disposeBag)
        
        //MARK: - Output
        viewModel.outputs.settings
            .drive(onNext: { [weak self] in
                let tableHeight = CGFloat($0.count) * 60.0
                self?.tableView.snp.updateConstraints { make in make.height.equalTo(tableHeight) }
                self?.dataSource.load(settings: $0)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    @objc func didTapBackgroundView() {
        delegate?.closeSettings()
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}

extension SettingsViewController {
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupBackgroundViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.defaultReusableId)
        tableView.estimatedRowHeight = 200
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        //tableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(100)
        }
    }
    
    private func setupTableBackgroundView() {
        tableBackgroundView = UIView()
        tableBackgroundView.backgroundColor = UIColor.white
        
        view.insertSubview(tableBackgroundView, belowSubview: tableView)
        tableBackgroundView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(view)
            make.width.equalTo(tableView.snp.width)
        }
    }
    
    private func setupOpaqueButton() {
        opaqueButton = UIButton()
        opaqueButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        opaqueButton.addTarget(self, action: #selector(didTapBackgroundView), for: .touchUpInside)
        
        view.addSubview(opaqueButton)
        opaqueButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(view)
            make.left.equalTo(tableView.snp.right)
        }
    }
    
}
