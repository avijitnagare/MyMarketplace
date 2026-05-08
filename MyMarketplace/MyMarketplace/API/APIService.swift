//
//  APIService.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import Foundation

final class APIService: APIServiceProtocol {
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
        }
    }
    
    
}
