//
//  APIServiceProtocol.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import Foundation

protocol APIServiceProtocol {
    func callApiWith<Model: Decodable>(model: Model.Type, completion: @escaping (Result<Model, Error>) -> Void)
    func addFidoItem(_ item: FidoItem, isPost: Bool) async -> FidoItem?
}

typealias APIParseResponse = (response: AnyObject, error: Error?)
