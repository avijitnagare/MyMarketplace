//
//  APIService.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import Foundation
import Combine

final class APIService: APIServiceProtocol {
    
    static let shared = APIService()
        
    static var endPoint = "http://localhost:8080/getFidoItems"
        
    static var cancellables = Set<AnyCancellable>()
    
    func callApiWith<Model>(model: Model.Type, completion: @escaping (Result<Model, any Error>) -> Void) where Model : Decodable {
        if EnvironmentManager.shared.isMock {
            //Load local file
            do {
                guard let filePath = Bundle.main.path(forResource: "fidoMock", ofType: "json") else {
                    return
                }
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
                let decodedData = try JSONDecoder().decode(Model.self, from: jsonData)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        } else {
            //API call
            URLSession.shared.dataTaskPublisher(for: URL(string: APIService.endPoint)!)
                .receive(on: DispatchQueue.main)
                .map(\.data)
                .decode(type: Model.self, decoder: JSONDecoder())
                .sink { status in
                    // This handles the end of the stream, whether it finished normally or failed
                    switch status {
                    case .finished:
                        print("Successfully finished")
                    case .failure(let error):
                        print("Finished with error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } receiveValue: { items in
                    // This handles the actual data (e.g., your [FidoItem])
                    print("Received \(items) items")
                    completion(.success(items))
                }
                .store(in: &APIService.cancellables)
        }
    }

    func addFidoItem(_ item: FidoItem, isPost: Bool = true) async -> FidoItem? {
          let url = isPost ? URL(string: APIService.endPoint)! : URL(string: "\(APIService.endPoint)/\(item.serverId ?? 0)")!
          var request = URLRequest(url: url)
          request.httpMethod = isPost ? "POST" :"PUT"
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          
          do {
              request.httpBody = try JSONEncoder().encode(item)
              
              // Perform the request
              let (data, response) = try await URLSession.shared.data(for: request)
              
              // 1. Check the Status Code
              guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                  return nil
              }
              
              // 2. Decode the Data into your Model
              // Assuming FidoItem conforms to Codable
              let decoder = JSONDecoder()
              let serverItem = try decoder.decode(FidoItem.self, from: data)
              
              return serverItem
          } catch {
              print("Update error: \(error)")
              return nil
          }
      }
    
}
