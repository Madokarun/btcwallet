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
    @Published var address: String = "address"
    @Published var value: Int = 0
    var mainnet = false
    
    init(){
        //let array:[String]? = ["rose", "galaxy", "govern", "repeat", "adult", "middle", "abuse", "faith", "enlist", "around", "elephant", "patch"]
        let array:[String]? = ["trigger", "nose", "perfect", "broken", "online", "sentence", "flavor", "garden", "impact", "raven", "injury", "rude", "runway", "draft", "pepper"]
        if(array != nil){
            if(mainnet){
                self.bitcoin = try? BitcoinKit(withWords: array!, bip: .bip44 , walletId: "bitcoin-wallet-id", syncMode: .api, networkType: .mainNet, logger: .none)
            }else{
                self.bitcoin = try? BitcoinKit(withWords: array!, bip: .bip44 , walletId: "bitcoin-wallet-id", syncMode: .api, networkType: .testNet, logger: .none)
            }
            for i in 0...array!.count - 1 {
                self.mnemonic.append(MnemonicArray(id: i, keyword: array![i]))
            }
            CheckData()
        }else{
            ResetAddress()
        }
        bitcoin!.balance
        bitcoin!.start()
    }
    
    func CheckData(){
        self.address = self.bitcoin!.receiveAddress()
        self.value = self.bitcoin!.balance.spendable
    }
    
    func Validate(address: String, value: Double, fee: Int)->Double{
        do{
            let satoshi_value = Int(value * satoshi)
            return Double(try bitcoin!.fee(for: satoshi_value, feeRate: fee))
        }catch{
            return 0
        }
    }
    
    func SendCoin(address: String, value: Double, fee: Int)->Bool{
        do{
            let satoshi_value = Int(value * satoshi)
            try self.bitcoin!.send(to: address, value: satoshi_value, feeRate: fee, sortType: .shuffle)
            return true
        }catch{
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
            CheckData()
        }catch{
            CheckData()
        }
    }
}

var test = Wallet()
let string1 = String(format: "%.10f", Double(test.value) / satoshi)
test.address
//let string2 = test.Validate(address: "mkHS9ne12qx9pS9VojpwU5xtRd4T7X7ZUt", value: 0.00005, fee: 1) / satoshi
//String(format: "%.8f", string2)
//test.SendCoin(address: "mkHS9ne12qx9pS9VojpwU5xtRd4T7X7ZUt", value: 0.01555991, fee: 100)
