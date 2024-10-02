//
//  NetworkManager.swift
//  LinkShortener
//
//  Created by Azad KIZILTAŞ on 2.10.2024.
//

import CoreData

class DataManager: ObservableObject {
    @Published var shortedLink: String = ""

    func shortLink(longUrl: String, completion: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: "\(Constants.BASE_URL)shorten_link?apikey=\(Constants.API_KEY)&url=\(longUrl)") else {
            print("Invalid URL")
            onError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                onError(error) // Hata durumunda
                return
            }

            guard let data = data else {
                print("No data")
                onError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON Response: \(jsonString)")
                }

                let linkModel = try JSONDecoder().decode(LinkModel.self, from: data)
                    completion(linkModel.data)
                
            } catch let jsonError {
                print("Error decoding JSON: \(jsonError)")
                onError(jsonError) // JSON decoding hatası
            }
        }.resume()
    }


    // Core Data'ya link kaydetme
    func saveLinkToDatabase(link: String,longUrl: String) {
        let context = PersistenceController.shared.container.viewContext
        let newLink = LinkShortenerModel(context: context)
        newLink.shortedUrl = link
        newLink.longUrl = longUrl

        do {
            try context.save()
            print("Link saved to database")
        } catch {
            print("Failed to save link: \(error.localizedDescription)")
        }
    }

    // Core Data'dan linkleri getirme
    func fetchLinksFromDatabase() -> [LinkShortenerModel] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<LinkShortenerModel> = LinkShortenerModel.fetchRequest()

        do {
            let links = try context.fetch(fetchRequest)
            return links
        } catch {
            print("Failed to fetch links: \(error.localizedDescription)")
            return []
        }
    }
    
    // Core Data'dan link silme
    func deleteLinkFromDatabase(linkToDelete: LinkShortenerModel) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(linkToDelete)

        do {
          try context.save()
          print("Link deleted from database")
        } catch {
          print("Failed to delete link: \(error.localizedDescription)")
        }
      }
    
}


struct LinkModel: Codable {
    let data: String
}
