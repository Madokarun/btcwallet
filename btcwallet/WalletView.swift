//
//  WalletView.swift
//  btcwallet
//
//  Created by Kazunori Tsuchiya on 2021/01/29.
//

import SwiftUI
import SwiftUIRefresh
import UIKit
import MobileCoreServices

struct WalletView: View {
    @State private var CopyAlert = false
    @State private var isShowing = false
    @ObservedObject var btcwallet: Wallet
    
    var body: some View {
        VStack(alignment: .leading) {
            List{
                Section(header: Text("ADDRESS")){
                    HStack{
                        Spacer()
                        Image(uiImage: UIImage.makeQRCode(text: "\(btcwallet.address)")!)
                            .resizable()
                            .frame(width: 100.0, height: 100.0, alignment: .leading)
                        Spacer()
                    }
                    Text("\(btcwallet.address)")
                    }.onLongPressGesture{
                        //btcwallet.CheckData()
                        UIPasteboard.general.setValue(btcwallet.address,
                                    forPasteboardType: kUTTypePlainText as String)
                        self.CopyAlert = true
                    }.alert(isPresented: $CopyAlert) {
                        Alert(title: Text("Copied Address"))
                }
                Section(header: Text("VALUE")){
                    Text("\(btcwallet.spendable)" + " BTC")
                }
            }.listStyle(InsetGroupedListStyle())
        }
            .pullToRefresh(isShowing: $isShowing) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            btcwallet.CheckData()
                            self.isShowing = false
                        }
            }
    }
}
