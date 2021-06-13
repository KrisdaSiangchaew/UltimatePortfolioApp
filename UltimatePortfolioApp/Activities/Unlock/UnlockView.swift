//
//  UnlockView.swift
//  UltimatePortfolioApp
//
//  Created by Krisda on 13/6/2564 BE.
//

import SwiftUI
import StoreKit

struct UnlockView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var unlockManager: UnlockManager
    
    var body: some View {
        VStack {
            switch unlockManager.requestState {
            case .loaded(let product):
                ProductView(product: product)
            case .failed(_):
                Text("Sorry, there was an error loading the store. Please try again later.")
            case .loading:
                ProgressView("Loading...")
            case .purchased:
                Text("Thank you!")
            case .deferred:
                Text("Thank you! Your request is pending approval, but you can carry on using the app.")
            }
            
            Button("Dismiss", action: dismiss)
        }
        .padding()
        .onReceive(unlockManager.$requestState) { value in
            if case .purchased = value {
                dismiss()
            }
        }
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
