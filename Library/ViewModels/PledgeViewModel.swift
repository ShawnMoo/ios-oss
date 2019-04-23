import KsApi
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var amountAndCurrencyAndDeliveryDate: Signal<(Double, String, String), NoError> { get }
}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel: PledgeViewModelType, PledgeViewModelInputs, PledgeViewModelOutputs {
  public init() {
    let projectAndReward = Signal.combineLatest(
      self.configureProjectAndRewardProperty.signal, self.viewDidLoadProperty.signal
    )
      .map(first)
      .skipNil()

    self.amountAndCurrencyAndDeliveryDate = projectAndReward.signal
      .map { (project, reward) in
        (reward.minimum, currencySymbol(forCountry: project.country).trimmed(), reward.estimatedDeliveryOn.map {
         Format.date(secondsInUTC: $0, template: "MMMMyyyy", timeZone: UTCTimeZone)
          } ?? "")
    }
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let amountAndCurrencyAndDeliveryDate: Signal<(Double, String, String), NoError>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
