//
//  NetworkRouting.swift
//  MovieQuiz
//
//  Created by Nastya on 15.10.2024.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
