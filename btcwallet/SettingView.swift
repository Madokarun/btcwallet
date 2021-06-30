//
//  SettingView.swift
//  btcwallet
//
//  Created by Kazunori Tsuchiya on 2021/01/29.
//

import BitcoinKit
import SwiftUI

struct SettingView: View {
    @State private var AddressAlert = false
    @State private var SettingAlert = false
    @ObservedObject var btcwallet: Wallet
    
    var body: some View {
        VStack(alignment: .leading) {
            List{
                Section(header: Text("MNEMONIC")){
                    ForEach(btcwallet.mnemonic){ array in
                        Text("\(array.keyword)")
                    }
                }
                NavigationLink(destination: EditView(btcwallet: btcwallet), isActive: $SettingAlert) {
                    Text("Recovery").foregroundColor(Color.blue)
                    }
                Button(action: {
                    self.AddressAlert = true
                }){
                    Text("Reset").foregroundColor(Color.red)
                }.alert(isPresented: $AddressAlert) {
                    Alert(title: Text("Caution"),
                        message: Text("Memo OK?"),
                        primaryButton: .cancel(Text("Cancel")), secondaryButton: .destructive(Text("Reset"), action:{btcwallet.ResetAddress()} ))
                    }
                }
        }.listStyle(InsetGroupedListStyle())
    }
}

struct EditView: View {
    @ObservedObject var btcwallet: Wallet
    @State private var ResetAlert = false
    @State private var s = ["", "", "", "", "", "", "", "", "", "", "", ""]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(alignment: .leading){
            List{
                ForEach(0..<12) {(i: Int) in
                    TextField("Keyword \(i + 1)", text: $s[i])
                }
            }
            Button(action: {
                btcwallet.RecoveryAddress(s)
                self.presentationMode.wrappedValue.dismiss()
            }){
                HStack{
                    Spacer()
                    Text("Recovery")}
            }
        }.listStyle(InsetGroupedListStyle())
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
        
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(btcwallet: Wallet())
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(btcwallet: Wallet())
    }
}
