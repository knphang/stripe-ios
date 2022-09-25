//
//  InformationViewController.swift
//  StripeFinancialConnections
//
//  Created by Krisjanis Gaidis on 7/25/22.
//

import Foundation
import UIKit
@_spi(STP) import StripeUICore

/// A reusable view that allows developers to quickly
/// render information.
final class ReusableInformationView: UIView {
    
    enum IconType {
        case icon
        case loading
    }
    
    struct ButtonConfiguration {
        let title: String
        let action: () -> Void
    }
    
    private let primaryButtonAction: (() -> Void)?
    private let secondaryButtonAction: (() -> Void)?
    
    init(
        iconType: IconType,
        title: String,
        subtitle: String,
        // the primary button is the bottom-most button
        primaryButtonConfiguration: ButtonConfiguration? = nil,
        secondaryButtonConfiguration: ButtonConfiguration? = nil
    ) {
        self.primaryButtonAction = primaryButtonConfiguration?.action
        self.secondaryButtonAction = secondaryButtonConfiguration?.action
        super.init(frame: .zero)
        backgroundColor = .customBackgroundColor
        
        let paneLayoutView = PaneWithHeaderLayoutView(
            icon: .view(CreateIconView(iconType: iconType)),
            title: title,
            subtitle: subtitle,
            contentView: UIView(),
            footerView: CreateFooterView(
                primaryButtonConfiguration: primaryButtonConfiguration,
                secondaryButtonConfiguration: secondaryButtonConfiguration,
                view: self
            )
        )
        paneLayoutView.addTo(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func didSelectPrimaryButton() {
        primaryButtonAction?()
    }
    
    @objc fileprivate func didSelectSecondaryButton() {
        secondaryButtonAction?()
    }
}

private func CreateIconView(iconType: ReusableInformationView.IconType) -> UIView {
    let iconContainerView = UIView()
    switch iconType {
    case .icon:
        iconContainerView.backgroundColor = .textDisabled
        iconContainerView.layer.cornerRadius = 4 // TODO(kgaidis): add support for icons when we decide how they are done...
    case .loading:
        iconContainerView.backgroundColor = .textBrand
        iconContainerView.layer.cornerRadius = 20 // TODO(kgaidis): fix temporary "icon" styling before we get loading icons
    }
    
    iconContainerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        iconContainerView.widthAnchor.constraint(equalToConstant: 40),
        iconContainerView.heightAnchor.constraint(equalToConstant: 40),
    ])
    return iconContainerView
}

private func CreateFooterView(
    primaryButtonConfiguration: ReusableInformationView.ButtonConfiguration?,
    secondaryButtonConfiguration: ReusableInformationView.ButtonConfiguration?,
    view: ReusableInformationView
) -> UIView? {
    guard
        primaryButtonConfiguration != nil || secondaryButtonConfiguration != nil
    else {
        return nil // display no footer
    }
    let footerStackView = UIStackView()
    footerStackView.axis = .vertical
    footerStackView.spacing = 12
    if let secondaryButtonConfiguration = secondaryButtonConfiguration {
        let secondaryButton = Button(
            configuration: {
                var continueButtonConfiguration = Button.Configuration.secondary()
                continueButtonConfiguration.font = .stripeFont(forTextStyle: .bodyEmphasized)
                continueButtonConfiguration.foregroundColor = .textSecondary
                continueButtonConfiguration.backgroundColor = .borderNeutral
                return continueButtonConfiguration
            }()
        )
        secondaryButton.title = secondaryButtonConfiguration.title
        secondaryButton.addTarget(view, action: #selector(ReusableInformationView.didSelectSecondaryButton), for: .touchUpInside)
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondaryButton.heightAnchor.constraint(equalToConstant: 56),
        ])
        footerStackView.addArrangedSubview(secondaryButton)
    }
    if let primaryButtonConfiguration = primaryButtonConfiguration {
        let primaryButton = Button(
            configuration: {
                var continueButtonConfiguration = Button.Configuration.primary()
                continueButtonConfiguration.font = .stripeFont(forTextStyle: .bodyEmphasized)
                continueButtonConfiguration.backgroundColor = .textBrand
                return continueButtonConfiguration
            }()
        )
        primaryButton.title = primaryButtonConfiguration.title
        primaryButton.addTarget(view, action: #selector(ReusableInformationView.didSelectPrimaryButton), for: .touchUpInside)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            primaryButton.heightAnchor.constraint(equalToConstant: 56),
        ])
        footerStackView.addArrangedSubview(primaryButton)
    }
    return footerStackView
}

#if DEBUG

import SwiftUI

@available(iOS 13.0, *)
private struct ReusableInformationViewUIViewRepresentable: UIViewRepresentable {
    
    let primaryButtonConfiguration: ReusableInformationView.ButtonConfiguration?
    let secondaryButtonConfiguration: ReusableInformationView.ButtonConfiguration?
    
    func makeUIView(context: Context) -> ReusableInformationView {
        ReusableInformationView(
            iconType: .loading,
            title: "Establishing connection",
            subtitle: "Please wait while a connection is established.",
            primaryButtonConfiguration: primaryButtonConfiguration,
            secondaryButtonConfiguration: secondaryButtonConfiguration
        )
    }
    
    func updateUIView(_ uiView: ReusableInformationView, context: Context) {}
}

struct ReusableInformationView_Previews: PreviewProvider {
    @available(iOS 13.0.0, *)
    static var previews: some View {
        VStack {
            ReusableInformationViewUIViewRepresentable(
                primaryButtonConfiguration: ReusableInformationView.ButtonConfiguration(
                    title: "Try Again",
                    action: {}
                ),
                secondaryButtonConfiguration: ReusableInformationView.ButtonConfiguration(
                    title: "Enter Bank Details Manually",
                    action: {}
                )
            )
            .frame(width: 320)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        
        VStack {
            ReusableInformationViewUIViewRepresentable(
                primaryButtonConfiguration: nil,
                secondaryButtonConfiguration: nil
            )
                .frame(width: 320)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

#endif
