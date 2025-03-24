//
//  NetworkScanner.swift
//  gyro
//
//  Created by rillo on 24.03.25.
//

import Network
import SwiftUI

struct ZeroconfConnection: Identifiable {
    let id: UUID = UUID()
    var name: String
    var addr: String
    var port: Int
    //var endpoint: NWEndpoint
}

class NetworkScanner: ObservableObject {
    @Published var endpoints: [ZeroconfConnection] = []
    private var browser: NWBrowser?
    
    func startScan() {
        endpoints.removeAll()
        
        let params = NWParameters()
        params.includePeerToPeer = false
        let bonjourType = "_blender-cam._tcp"
        
        browser = NWBrowser(for: .bonjourWithTXTRecord(type: bonjourType, domain: "local"), using: params)
        
        browser?.browseResultsChangedHandler = {
            results, changes in
            for result in results {
                print(result)
                                
                if case NWBrowser.Result.Metadata.bonjour(let txtRecord) = result.metadata {
                    let d = txtRecord.dictionary
                    //print(txtRecord.dictionary["ip"], txtRecord.dis)
                    if d["service"] != nil
                        && d["ip"] != nil
                        && d["port"] != nil {
                        self.endpoints.append(ZeroconfConnection(name: d["service"]!, addr: d["ip"]!, port: Int(d["port"]!)! ))
                    }                    
                }
            }
        }
        browser?.start(queue: .main)
    }
    
    func stopScanner() {
        browser?.cancel()
    }
}
