//
//  PaymentView.swift
//  btcwallet
//
//  Created by Kazunori Tsuchiya on 2021/01/29.
//

import SwiftUI
import BitcoinKit
import CodeScanner

struct PaymentView: View {
    @State private var scannedCode: String?
    @ObservedObject var btcwallet: Wallet

    var body: some View {
        NavigationView {
            VStack{
                CodeScannerView(
                    codeTypes: [.qr],
                    completion: { result in
                        if case let .success(code) = result {
                            self.scannedCode = code
                        }
                    }
                )
                if self.scannedCode != nil{
                    NavigationLink("Next", destination:SendView(btcwallet: btcwallet, scannedCode: $scannedCode) , isActive:.constant(true) ).hidden()
                }
            }
        }
    }
}

struct SendView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var btcwallet: Wallet
    @Binding var scannedCode: String?
    @State private var successAlert = false
    @State private var failureAlert = false
    @State var value = ""
    @State var fee = ""
    @State var fee_check: Double = 0
    
    var body: some View {
        NavigationView (){
            VStack{
                Text("address")
                Text(scannedCode!)
                Text("spendable value")
                Text("\(btcwallet.spendable)")

                TextField("Value (BTC)", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()
                TextField("Fee (Satoshi)", text: $fee)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()
                VStack{
                    Button(action: {
                        if(Double(value) == nil){
                            value = "0"
                        }
                        if(Int(fee) == nil){
                            fee = "0"
                        }
                        fee_check = btcwallet.Validate(address: scannedCode!, value: Double(value)!, fee: Int(fee)!)
                        if(fee_check != 0){
                            successAlert = true
                        }else{
                            failureAlert = true
                        }
                        }){
                                Text("Send")
                            }
                    NavigationLink(destination: CheckView(btcwallet: btcwallet, value: $value, fee: $fee, fee_check: $fee_check, scannedCode: $scannedCode), isActive: $successAlert) {
                        EmptyView()
                    }
                    NavigationLink(destination: EmptyCoinView(), isActive: $failureAlert) {
                        EmptyView()
                    }
                }
            }
        }.navigationBarBackButtonHidden(true)
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
    }
}

struct CheckView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var btcwallet: Wallet
    @State private var successAlert = false
    @State private var failureAlert = false
    @Binding var value: String
    @Binding var fee: String
    @Binding var fee_check: Double
    @Binding var scannedCode: String?
    
    var body: some View{
        VStack{
            Text("send value")
            Text(value + " BTC")
            Text("now_fee")
            Text(String(format: "%.7f BTC", fee_check))
            Text("OK?")
            
            VStack{
                Button(action: {
                            self.presentation.wrappedValue.dismiss()
                        }, label: {
                            Text("Back to Input Menu")
                        })
                Button(action: {
                    let check = btcwallet.SendCoin(address: scannedCode!, value: Double(value)!, fee: Int(fee)!)
                        if(check){
                            successAlert = true
                        }else{
                            failureAlert = true
                        }
                    }){
                    Text("Send")
                }
                NavigationLink(destination: SendedView(), isActive: $successAlert) {
                    EmptyView()
                }
                NavigationLink(destination: ErrorView(), isActive: $failureAlert) {
                    EmptyView()
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct EmptyCoinView: View {
    @Environment(\.presentationMode) var presentation
    
    var body: some View{
        VStack{
            Text("Input value is too lower.")
            Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("Back to Input Menu")
                    })
        }.navigationBarBackButtonHidden(true)
    }
}

struct SendedView: View {
    var body: some View{
        VStack {
            Text("Bitcoin was send!")
        }.navigationBarBackButtonHidden(true)
    }
}

struct ErrorView: View {
    @Environment(\.presentationMode) var presentation
    
    var body: some View{
        VStack{
            Text("Bitcoin wasn't send")
            Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("Back to Input Menu")
                    })
        }.navigationBarBackButtonHidden(true)
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(btcwallet: Wallet())
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
