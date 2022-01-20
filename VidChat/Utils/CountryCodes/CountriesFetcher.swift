//
//  CountriesFetcher.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-19.
//

import Foundation

class CountriesFetcher {
    
    func fetch() -> [Country] {
        
        let url = Bundle.main.url(forResource: "Countries", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let countries = try! decoder.decode([Country].self, from: data)
        
        return countries
        
    }
    
    
}
