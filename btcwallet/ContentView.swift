//
//  ContentView.swift
//  btcwallet
//
//  Created by Kazunori Tsuchiya on 2021/01/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var btcwallet = Wallet()
    var body: some View {
        TabView {
            NavigationView{
                WalletView(btcwallet: btcwallet)
                .navigationTitle("Wallet")
            }
                .tabItem {
                    Image(systemName: "bitcoinsign.circle.fill")
                    Text("Wallet")
            }
            NavigationView{
                PaymentView(btcwallet: btcwallet)
                .navigationTitle("Payment")
            }
                .tabItem {
                    Image(systemName: "paperplane.fill")
                    Text("Payment")
                }
            NavigationView{
                SettingView(btcwallet: btcwallet)
                .navigationTitle("Settings")
            }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                }
            }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

