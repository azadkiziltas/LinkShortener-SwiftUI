//
//  ContentView.swift
//  LinkShortener
//
//  Created by Azad KIZILTAŞ on 30.09.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    
    @State private var showCopyAlert: Bool = false // Kopyalama için alert
    @State private var showErrorAlert: Bool = false // Yapıştırma için alert
    
    @StateObject private var dataManager = DataManager()
    
    @State private var items: [LinkShortenerModel] = []
    
    var body: some View {
        VStack (spacing: 16) {
            
            Text("Shorted Links").font(.title)
            
            List {
                ForEach(items, id: \.self) { item in
                    HStack(content: {
                        VStack(alignment: .leading) {
                            Text(item.shortedUrl ?? "No Short URL").font(.headline)
                            Text(item.longUrl ?? "No Long URL").font(.subheadline)
                        }
                        Spacer()
                        Button(
                            action: {
                                UIPasteboard.general.string = item.shortedUrl
                                showCopyAlert = true // Kopyalama işlemi başarılı, alerti göster

                            }
                        ){
                            Image(systemName: "doc.on.doc")

                        }
                    }).padding().background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.black.opacity(0.05))
                    )
                    .contentShape(Rectangle())
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .onDelete(perform: deleteItem)
            }
            .listStyle(PlainListStyle())
            .onAppear {
                if items.isEmpty { // Eğer liste zaten doluysa bir daha fetch işlemi yapılmaz
                    let savedLinks = dataManager.fetchLinksFromDatabase()
                    items = savedLinks
                }
            }
            
            TextField("Enter your link here", text: $inputText)
                .textInputAutocapitalization(.never)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black.opacity(0.05))
                )
                .padding(.horizontal)
                .shadow(radius: 10)
            
            HStack(spacing: 16) {
                Button(action: {

                    if let pasteText = UIPasteboard.general.string {
                                            inputText = pasteText

                                        }

                }) {
                    Text("Paste")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    isLoading = true

                    dataManager.shortLink(longUrl: inputText) { shortedLink in
                        
                        if !items.contains(where: { $0.longUrl == inputText }) {

                            dataManager.saveLinkToDatabase(link: shortedLink, longUrl: inputText)
                            
                            items = dataManager.fetchLinksFromDatabase()
                        }
                        
                        
                        inputText = ""
                        isLoading = false
                    } onError: { error in
                        // Hata durumunda loading durdurulsun
                        print("Error: \(error.localizedDescription)")
                        isLoading = false
                        showErrorAlert = true // Hata alertini göster
                    }
                    
                    
                    print("Short Link button tapped. Input: \(inputText)")
                }) {
                    
                    if(!isLoading) {
                        Text("Short Link")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white)) // ProgressView'e beyaz renk veriyoruz
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    

                }
            }
            .padding(.horizontal)
        }.alert(isPresented: .constant(showCopyAlert || showErrorAlert)) {
            if showCopyAlert {
                return Alert(title: Text("Link Copied!"), message: Text("The short URL has been copied to your clipboard."), dismissButton: .default(Text("OK"), action: {
                    showCopyAlert = false
                }))
            } 
            else {
                return Alert(title: Text("Error!"), message: Text("Please check your link."), dismissButton: .default(Text("OK"), action: {
                    showErrorAlert = false
                }))
            }
            
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            // Silinecek link modelini al
            let linkToDelete = items[index]
            
            // Core Data'dan linki sil
            dataManager.deleteLinkFromDatabase(linkToDelete: linkToDelete)
            
            // Listedeki item'ı kaldır
            items.remove(at: index)
        }
    }
}


#Preview {
    ContentView()
}
