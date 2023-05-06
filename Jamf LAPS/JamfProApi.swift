//
//  JamfProApi.swift
//  Jamf LAPS
//
//  Created by Richard Mallion on 06/05/2023.
//

import Foundation


struct JamfProAPI {
    
    
    var username: String
    var password: String
    
    var base64Credentials: String {
        return "\(username):\(password)"
            .data(using: String.Encoding.utf8)!
            .base64EncodedString()
    }
    
    func getToken(jssURL: String, base64Credentials: String) async -> (JamfAuth?,Int?) {
        guard var jamfAuthEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfAuthEndpoint.path="/api/v1/auth/token"

        guard let url = jamfAuthEndpoint.url else {
            return (nil, nil)
        }

        var authRequest = URLRequest(url: url)
        authRequest.httpMethod = "POST"
        authRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        guard let (data, response) = try? await URLSession.shared.data(for: authRequest)
        else {
            return (nil, nil)
        }
        
        let httpResponse = response as? HTTPURLResponse
        
        do {
            let jssToken = try JSONDecoder().decode(JamfAuth.self, from: data)
            return (jssToken, httpResponse?.statusCode)
        } catch _ {
            return (nil, httpResponse?.statusCode)
        }
    }
    
    func fetchSettings(jssURL: String, authToken: String) async -> (LAPSSettings?,Int?) {
        guard var jamfcomputerEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfcomputerEndpoint.path="/api/v1/local-admin-password/settings"

        guard let url = jamfcomputerEndpoint.url else {
            return (nil , nil)
        }

        
        var settingsRequest = URLRequest(url: url)
        settingsRequest.httpMethod = "GET"
        settingsRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        settingsRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let (data, response) = try? await URLSession.shared.data(for: settingsRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        do {
            let lapsSettings = try JSONDecoder().decode(LAPSSettings.self, from: data)
            return (lapsSettings, httpResponse?.statusCode)
        } catch _ {
            return (nil, httpResponse?.statusCode)
        }
    }

    func saveSettings(jssURL: String, authToken: String, lapsSettings: LAPSSettings) async -> Int? {
        guard var jamfcomputerEndpoint = URLComponents(string: jssURL) else {
            return nil
        }
        
        jamfcomputerEndpoint.path="/api/v1/local-admin-password/settings"

        guard let url = jamfcomputerEndpoint.url else {
            return nil
        }

        
        var settingsRequest = URLRequest(url: url)
        settingsRequest.httpMethod = "PUT"
        settingsRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        settingsRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(lapsSettings)
            settingsRequest.httpBody = jsonData
        } catch let error {
            print("Could not endcode json \(error.localizedDescription)")
            return nil
        }

        
        guard let (data, response) = try? await URLSession.shared.data(for: settingsRequest)
        else {
            return nil
        }
        let httpResponse = response as? HTTPURLResponse
        return httpResponse?.statusCode
//        do {
//            let str = String(decoding: data, as: UTF8.self)
//            print(str)
//            let lapsSettings = try JSONDecoder().decode(LAPSSettings.self, from: data)
//            return httpResponse?.statusCode
//        } catch _ {
//            return httpResponse?.statusCode
//        }
    }

    
    
    func getComputerID(jssURL: String, authToken: String, serialNumber: String) async -> (Int?,Int?) {
        guard var jamfcomputerEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfcomputerEndpoint.path="/JSSResource/computers/serialnumber/\(serialNumber)"

        guard let url = jamfcomputerEndpoint.url else {
            return (nil, nil)
        }

        
        var computerRequest = URLRequest(url: url)
        computerRequest.httpMethod = "GET"
        computerRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        computerRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let (data, response) = try? await URLSession.shared.data(for: computerRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        do {
            let computer = try JSONDecoder().decode(Computer.self, from: data)
            return (computer.computer.general.id, httpResponse?.statusCode)
        } catch _ {
            return (nil, httpResponse?.statusCode)
        }
    }
    
    
    
    
    
    func getComputerManagementID(jssURL: String, authToken: String, id: Int) async -> (String?,Int?) {
        guard var jamfcomputerEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        jamfcomputerEndpoint.path="/api/v1/computers-inventory/\(id)"
        guard let url = jamfcomputerEndpoint.url else {
            return (nil, nil)
        }

        var managementidRequest = URLRequest(url: url)
        managementidRequest.httpMethod = "GET"
        managementidRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        managementidRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let (data, response) = try? await URLSession.shared.data(for: managementidRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        do {
            let computer = try JSONDecoder().decode(ComputerManagementId.self, from: data)
            return (computer.general.managementId, httpResponse?.statusCode)
        } catch _ {
            return (nil, httpResponse?.statusCode)
        }
    }
    
    func getLAPSPassword(jssURL: String, authToken: String, managementId: String) async -> (String?,Int?) {
        guard var jamfcomputerEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfcomputerEndpoint.path="/api/v1/local-admin-password/\(managementId)/account/jamfmdm/password"
        guard let url = jamfcomputerEndpoint.url else {
            return (nil, nil)
        }

        var passwordRequest = URLRequest(url: url)
        passwordRequest.httpMethod = "GET"
        passwordRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        passwordRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let (data, response) = try? await URLSession.shared.data(for: passwordRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        do {
            let lapsPassword = try JSONDecoder().decode(LAPSPassword.self, from: data)
            return (lapsPassword.password, httpResponse?.statusCode)
        } catch _ {
            return (nil, httpResponse?.statusCode)
        }
    }



    
}

// MARK: - LAPS Password
struct LAPSPassword: Codable {
    let password: String
}

// MARK: - Jamf Pro LAPS Settings
struct LAPSSettings: Codable {
    let autoDeployEnabled: Bool
    let passwordRotationTime: Int
    let autoExpirationTime: Int
}

// MARK: - Jamf Pro Auth Model
struct JamfAuth: Decodable {
    let token: String
    let expires: String
}


// MARK: - Computer Record
struct Computer: Codable {
    let computer: ComputerDetail
}

// MARK: - Computer Model
struct ComputerDetail: Codable {
    let general: General

    enum CodingKeys: String, CodingKey {
        case general
    }
}

struct General: Codable {
    let id: Int
    enum CodingKeys: String, CodingKey {
        case id
    }
}


// MARK: - ComputerManagementId
struct ComputerManagementId: Decodable {
    let id: String
    let general: GeneralManagementId
    enum CodingKeys: String, CodingKey {
        case id
        case general
    }

}

struct GeneralManagementId: Codable {
    let managementId: String
    enum CodingKeys: String, CodingKey {
        case managementId
    }

}

