
import Foundation
import RxSwift
import RxCocoa
import SnapKit

protocol SettingsViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    var selectedSettingInput: AnyObserver<Setting> { get }
}

protocol SettingsModelOutputs {
    var settings: Driver<[Setting]> { get }
}

protocol SettingsViewModelType {
    var inputs: SettingsViewModelInputs { get }
    var outputs: SettingsModelOutputs { get }
}

final class SettingsViewModel: SettingsViewModelInputs, SettingsModelOutputs, SettingsViewModelType {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: SettingsViewModelInputs { return self }
    let viewDidLoadInput: AnyObserver<Void>
    let selectedSettingInput: AnyObserver<Setting>
    
    //MARK: - Outputs
    var outputs: SettingsModelOutputs { return self }
    let settings: Driver<[Setting]>
    
    //MARK: - Init
    init?() {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        
        let currentUser = Variable<User>(user)
        
        //MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _selectedSettingInput = PublishSubject<Setting>()
        
        //MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.selectedSettingInput = _selectedSettingInput.asObserver()
        
        //MARK: - First Level Observables
        let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        let selectedSettingObservable = _selectedSettingInput.asObservable()
        
        self.settings = viewDidLoadObservable
            .map { _ in createSettingOptions() }
            .asDriver(onErrorJustReturn: [])
        
        selectedSettingObservable
            .do(onNext: { $0.action() })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

private func createSettingOptions() -> [Setting] {
    let settingTypes: [SettingType] = [.feedback, .share, .logout]
    return settingTypes.map { (type) -> Setting in
        switch type {
        case .feedback:
            return Setting(type: type, iconImage: #imageLiteral(resourceName: "IC_Feedback"), action: {
                print("Feedback action")
            })
        case .share:
            return Setting(type: type, iconImage: #imageLiteral(resourceName: "IC_Share"), action: {
                print("Share action")
            })
        case .logout:
            return Setting(type: type, iconImage: #imageLiteral(resourceName: "IC_Logout"), action: {
                print("logout action")
                RealmAuth.resetDefaultRealm()
                NotificationCenter.default.post(name: .logout, object: nil)
            })
        }
    }
}

