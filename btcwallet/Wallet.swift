//
//  Wallet.swift
//  btcwallet
//
//  Created by Kazunori Tsuchiya on 2021/01/26.
//

import Foundation
import UIKit
import BitcoinKit
import MnemonicSwift
import HdWalletKit

let satoshi: Double = 100000000

struct MnemonicArray: Identifiable{
    var id: Int
    var keyword: String

    init(id: Int, keyword: String){
        self.id = id
        self.keyword = keyword
    }
}

class Wallet: ObservableObject{
    @Published var bitcoin: BitcoinKit?
    @Published var mnemonic: [MnemonicArray] = []
    @Published var address = "address"
    @Published var spendable: Double = 0
    @Published var scannedCode: String? = ""
    
    init(){
        //let array = UserDefaults.standard.stringArray(forKey: "mnemonic")
        let array: [String]? = ["rose", "galaxy", "govern", "repeat", "adult", "middle", "abuse", "faith", "enlist", "around", "elephant", "patch"]
        if(array != nil){
            self.bitcoin = try? BitcoinKit(withWords: array!, bip: .bip44 , walletId: "bitcoin-wallet-id", syncMode: .api, networkType: .testNet, logger: .none)
            for i in 0...array!.count - 1 {
                self.mnemonic.append(MnemonicArray(id: i, keyword: array![i]))
            }
            CheckData()
        }else{
            ResetAddress()
        }
        bitcoin!.start()
    }
    
    func CheckData(){
        self.address = self.bitcoin!.receiveAddress()
        self.spendable = Double(self.bitcoin!.balance.spendable) / satoshi
    }
    
    func Validate(address: String, value: Double, fee: Int)->Double{
        let satoshi_value = Int(value * satoshi)
        do{
            try bitcoin!.validate(address: address)
            let fee = try bitcoin!.fee(for: satoshi_value, feeRate: fee)
            return Double(fee) / satoshi
        }catch{
            return 0
        }
    }
    
    func SendCoin(address: String, value: Double, fee: Int)->Bool{
        let satoshi_value = Int(value * satoshi)
        do{
            try self.bitcoin!.send(to: address, value: satoshi_value, feeRate: fee, sortType: .shuffle)
            return true
        }catch{
            print("error")
            return false
        }
    }
    
    func ResetAddress(){
        let mnemonic = try? Mnemonic.generateMnemonic(strength: 128, language: .english)
        let array = mnemonic!.components(separatedBy: " ")
        UserDefaults.standard.set(array, forKey: "mnemonic")
        
        self.bitcoin = try? BitcoinKit(withWords: array, bip: .bip44 , walletId: "bitcoin-wallet-id", syncMode: .api, networkType: .testNet, logger: .none)
        self.mnemonic = []
        for i in 0...array.count - 1 {
            self.mnemonic.append(MnemonicArray(id: i, keyword: array[i]))
        }
        CheckData()
    }
    
    func RecoveryAddress(_ s: [String]){
        do{
            try self.bitcoin = BitcoinKit(withWords: s, bip: .bip44 , walletId: "bitcoin-wallet-id", syncMode: .api, networkType: .testNet, logger: .none)
            UserDefaults.standard.set(s, forKey: "mnemonic")
            self.mnemonic = []
            for i in 0...s.count - 1 {
                self.mnemonic.append(MnemonicArray(id: i, keyword: s[i]))
            }
        }catch{
            var array: [String] = []
            for i in 0...self.mnemonic.count{
                array.append(self.mnemonic[i].keyword)
            }
            self.bitcoin = try? BitcoinKit(withWords: array, bip: .bip44 , walletId: "bitcoin-wallet-id", syncMode: .api, networkType: .testNet, logger: .none)
            UserDefaults.standard.set(self.mnemonic, forKey: "mnemonic")
        }
        CheckData()
    }
    
}

extension UIImage {
    static func makeQRCode(text: String) -> UIImage? {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let QR = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data]) else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let ciImage = QR.outputImage?.transformed(by: transform) else { return nil }
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
