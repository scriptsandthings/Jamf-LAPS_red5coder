//
//  JamfProApi.swift
//  Jamf LAPS
//
//  Created by Richard Mallion on 06/05/2023.
//

import Foundation
import os.log

struct JamfProAPI {
    
    
    var username: String
    var password: String
    
    var base64Credentials: String {
        return "\(username):\(password)"
            .data(using: String.Encoding.utf8)!
            .base64EncodedString()
    }
    
    func getToken(jssURL: String, base64Credentials: String) async -> (JamfAuth?,Int?) {
        Logger.laps.info("About to fetch Authentication Token")
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
        Logger.laps.info("Fetching Authentication Token")
        guard let (data, response) = try? await URLSession.shared.data(for: authRequest)
        else {
            return (nil, nil)
        }
        
        let httpResponse = response as? HTTPURLResponse
        
        if let response = httpResponse?.statusCode {
            Logger.laps.info("Response code for authentication: \(response, privacy: .public)")
        }
        
        do {
            let jssToken = try JSONDecoder().decode(JamfAuth.self, from: data)
            
            return (jssToken, httpResponse?.statusCode)
            Logger.laps.info("Authentication token received")
        } catch _ {
            Logger.laps.error("No authentication token received")
            return (nil, httpResponse?.statusCode)
        }
    }
    
    func fetchSettings(jssURL: String, authToken: String) async -> (LAPSSettings?,Int?) {
        Logger.laps.info("About to fetch LAPS Settings")
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
        Logger.laps.info("Fetching LAPS Settings")
        guard let (data, response) = try? await URLSession.shared.data(for: settingsRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        if let response = httpResponse?.statusCode {
            Logger.laps.info("Response code for fetching laps settings: \(response, privacy: .public)")
        }
        do {
            let lapsSettings = try JSONDecoder().decode(LAPSSettings.self, from: data)
            Logger.laps.info("LAPS Settings received")
            return (lapsSettings, httpResponse?.statusCode)
        } catch _ {
            Logger.laps.error("LAPS Settings received")
            return (nil, httpResponse?.statusCode)
        }
    }

    func saveSettings(jssURL: String, authToken: String, lapsSettings: LAPSSettings) async -> Int? {
        Logger.laps.info("About to save LAPS settings")
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

        Logger.laps.info("Saving LAPS settings")

        guard let (data, response) = try? await URLSession.shared.data(for: settingsRequest)
        else {
            return nil
        }
        let httpResponse = response as? HTTPURLResponse
        if let response = httpResponse?.statusCode {
            Logger.laps.info("Response code for saving LAPS settings: \(response, privacy: .public)")
        }
        return httpResponse?.statusCode
    }

    
    
    func getComputerID(jssURL: String, authToken: String, serialNumber: String) async -> (Int?,Int?) {
        Logger.laps.info("About to fetch the computer id for \(serialNumber)")

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
        Logger.laps.info("Fetching Computer ID")
        guard let (data, response) = try? await URLSession.shared.data(for: computerRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        if let response = httpResponse?.statusCode {
            Logger.laps.info("Response code for fetching computer id: \(response, privacy: .public)")
        }
        do {
            let computer = try JSONDecoder().decode(Computer.self, from: data)
            Logger.laps.info("Computer ID found: \(computer.computer.general.id, privacy: .public)")
            return (computer.computer.general.id, httpResponse?.statusCode)
        } catch _ {
            Logger.laps.error("No Computer ID found")
            return (nil, httpResponse?.statusCode)
        }
    }
    
    
    
    
    
    func getComputerManagementID(jssURL: String, authToken: String, id: Int) async -> (String?,Int?) {
        Logger.laps.info("About to fetch ManagementID for computer id \(id)")
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
        Logger.laps.info("Fetching Management ID")
        guard let (data, response) = try? await URLSession.shared.data(for: managementidRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        if let response = httpResponse?.statusCode {
            Logger.laps.info("Response code for fetching management id: \(response, privacy: .public)")
        }
        do {
            let computer = try JSONDecoder().decode(ComputerManagementId.self, from: data)
            Logger.laps.info("Management ID found: \(computer.general.managementId, privacy: .public)")
            return (computer.general.managementId, httpResponse?.statusCode)
        } catch _ {
            Logger.laps.error("No Management ID found")
            return (nil, httpResponse?.statusCode)
        }
    }
    
    func getLAPSPassword(jssURL: String, authToken: String, managementId: String, username: String) async -> (String?,Int?) {
        Logger.laps.info("About to fetch the LAPS password for computer with management id of \(managementId) and user name of \(username)")
        guard var jamfcomputerEndpoint = URLComponents(string: jssURL) else {
            return (nil, nil)
        }
        
        jamfcomputerEndpoint.path="/api/v1/local-admin-password/\(managementId)/account/\(username)/password"
        guard let url = jamfcomputerEndpoint.url else {
            return (nil, nil)
        }
        Logger.laps.info("LAPS Request URL: \(jamfcomputerEndpoint.path, privacy: .public)")
        var passwordRequest = URLRequest(url: url)
        passwordRequest.httpMethod = "GET"
        passwordRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        passwordRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        Logger.laps.info("Fetching LAPS password")
        guard let (data, response) = try? await URLSession.shared.data(for: passwordRequest)
        else {
            return (nil, nil)
        }
        let httpResponse = response as? HTTPURLResponse
        if let response = httpResponse?.statusCode {
            Logger.laps.info("Response code for authentication: \(response, privacy: .public)")
        }
        do {
            let lapsPassword = try JSONDecoder().decode(LAPSPassword.self, from: data)
            Logger.laps.info("LAPS password is: \(lapsPassword.password, privacy: .public)")
            return (lapsPassword.password, httpResponse?.statusCode)
        } catch _ {
            Logger.laps.error("No LAPS password found")
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

