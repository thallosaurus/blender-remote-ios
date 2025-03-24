//
//  ConnectView.swift
//  gyro
//
//  Created by rillo on 22.03.25.
//

import SwiftUI
import Network

//var client = Client()

struct ZeroconfConnection: Hashable {
    //let id: UUID = UUID()
    var endpoint: NWBrowser.Result
    var name: String
    var domain: String
}

class NetworkScanner: ObservableObject {
    @Published var discoveredServers: [ZeroconfConnection?] = []
    private var browser: NWBrowser?
    
    func startScan() {
        discoveredServers.removeAll()
        
        let params = NWParameters()
        params.includePeerToPeer = false
        let bonjourType = "_blender-cam._tcp"
        
        browser = NWBrowser(for: .bonjour(type: bonjourType, domain: "local"), using: params)
        
        browser?.browseResultsChangedHandler = {
            results, changes in
            for result in results {
                switch result.endpoint {
                    
                case .service(name: let name, type: _, domain: let domain, interface: _):
                    self.discoveredServers.append(ZeroconfConnection(endpoint: result, name: name, domain: domain))
                default:
                    continue
                }
                
                
                //self.discoveredServers.append(
            }
            
            /*self.discoveredServers = results.compactMap { result in
             switch result.endpoint {
             case .service(name: let name, type: _, domain: let domain, interface: _):
             switch result.metadata {
             case .bonjour(let txt):
             print(txt)
             }
             return ZeroconfConnection(endpoint: result, name: name, domain: domain)
             
             default:
             return nil
             }
             }*/
            
            
        }
        browser?.start(queue: .main)
    }
}

struct ConnectView: View {
    @State var host = ""
    @State var port = 56789
    @State var connected = false
    
    @StateObject private var client = Client()
    @StateObject private var scanner = NetworkScanner()
    
    var body: some View {
        VStack {
            if !client.isConnected {
                /*VStack {
                 VStack {
                 Spacer()
                 Text("Enter the IP Address of the Computer running the Blender AddOn")
                 Spacer()
                 HStack {
                 TextField("Host", text: $host)
                 TextField("Port", value: $port, format: .number)
                 }
                 Spacer()
                 Button("Connect") {
                 client.connect(host: host, port: port)
                 }
                 Spacer()
                 }
                 }.padding()*/
                NavigationStack {
                    VStack {
                        Form {
                            /*Section("Automatic") {
                                Button("Scan") {
                                    
                                    scanner.startScan()
                                }
                                List(scanner.discoveredServers, id: \.self) { server in
                                    Button(action: {
                                        if server != nil {
                                            client.connect(host: server!.domain, port: port)
                                        }
                                    }) {
                                        Text(server?.name ?? "Unknown Server")
                                    }
                                }
                            }*/
                            
                            Section("Manual Connection") {
                                LabeledContent(content: {
                                    TextField("Hostname", text: $host)
                                        .multilineTextAlignment(.trailing)
                                }) {
                                    Text("Name")
                                }
                                LabeledContent(content: {
                                    TextField("Port", value: $port, format: .number.grouping(.never))
                                        .multilineTextAlignment(.trailing)
                                }) {
                                    Text("Port")
                                }
                                Button(action: {
                                    client.connect(host: host, port: port)
                                }, label: {
                                    Text("Connect")
                                })
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Blender Virtual Camera")
                    .alert(isPresented: $client.error_occured){
                        Alert(title: Text("An error occured"),
                              dismissButton: .default(Text("Ok"))
                        )
                    }
                }
            } else {
                CameraListView()
            }
        }
        .environmentObject(client)
    }
}

#Preview {
    ConnectView()
        .environmentObject(Client())
}
