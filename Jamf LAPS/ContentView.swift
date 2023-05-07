//
//  ContentView.swift
//  Jamf LAPS
//
//  Created by Richard Mallion on 04/05/2023.
//

import SwiftUI
import os.log

struct ContentView: View {
    
    @State private var jamfURL = ""
    @State private var userName = ""
    @State private var password = ""
    @State private var savePassword = false

    //Settings
    @State private var autoDeployEnabled = false
    @State private var passwordRotationTime = ""
    @State private var autoExpirationTime = ""
    @State private var saveSettingsButtonDisabled = true
    
    @State private var passwordRotationTimeChanged = false
    @State private var autoExpirationTimeChanged = false
    @State private var enableLAPSChanged = false

    //Alert
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    //Password
    @State private var serialNumber = ""
    @State private var lapsUserName = ""
    @State private var lapsPassword = ""
    @State private var fetchPassewordButtonDisabled = true

    var body: some View {
        
        VStack(alignment: .trailing){
            
            HStack(alignment: .center) {
                
                VStack(alignment: .trailing, spacing: 12.0) {
                    Text("Jamf Server URL:")
                    Text("Username:")
                    Text("Password:")
                }
                
                VStack(alignment: .leading, spacing: 7.0) {
                    TextField("https://your-jamf-server.com" , text: $jamfURL)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: jamfURL) { newValue in
                            let defaults = UserDefaults.standard
                            defaults.set(jamfURL , forKey: "jamfURL")
        //                    updateAction()
                        }
                    TextField("Your Jamf Pro admin user name" , text: $userName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: userName) { newValue in
                            let defaults = UserDefaults.standard
                            defaults.set(userName , forKey: "userName")
        //                    updateAction()
                        }

                    SecureField("Your password" , text: $password)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: password) { newValue in
                            if savePassword {
                                DispatchQueue.global(qos: .background).async {
                                    Keychain().save(service: "co.uk.mallion.Jamf-LAPS", account: userName, data: password)
                                }
                            } else {
                                DispatchQueue.global(qos: .background).async {
                                    Keychain().save(service: "co.uk.mallion.Jamf-LAPS", account: "", data: "")
                                }
                            }
        //                    updateAction()
                        }
                }
            }
            .padding()

            Toggle(isOn: $savePassword) {
                Text("Save Password")
            }
            .toggleStyle(CheckboxToggleStyle())
            .offset(x: -260 , y: -10)
            .onChange(of: savePassword) { newValue in
                let defaults = UserDefaults.standard
                defaults.set(savePassword, forKey: "savePassword")
            }
            
            

        }
        .onAppear {
            let defaults = UserDefaults.standard
            userName = defaults.string(forKey: "userName") ?? ""
            jamfURL = defaults.string(forKey: "jamfURL") ?? ""
            savePassword = defaults.bool(forKey: "savePassword" )
            if savePassword  {
                let credentialsArray = Keychain().retrieve(service: "co.uk.mallion.Jamf-LAPS")
                if credentialsArray.count == 2 {
                    userName = credentialsArray[0]
                    password = credentialsArray[1]
                }
            }

        }
        
        
        //Settings
        Divider()
        HStack {
            Text("Local Administration Password Settings")
            Spacer()
        }
        .padding([.leading,.trailing, .bottom])

        HStack {
            Toggle("Enable LAPS", isOn: $autoDeployEnabled)
                .padding([.leading,.trailing])
                .toggleStyle(.switch)
                .onChange(of: autoDeployEnabled) { newValue in
                    print("1saveSettingsButtonDisabled \(saveSettingsButtonDisabled)")
                    print("1enableLAPSChanged \(enableLAPSChanged)")
                    saveSettingsButtonDisabled = false
                    if enableLAPSChanged {
                        saveSettingsButtonDisabled = true
                        enableLAPSChanged = false
                        print("saveSettingsButtonDisabled \(saveSettingsButtonDisabled)")
                        print("enableLAPSChanged \(enableLAPSChanged)")

                    }
                }
            Spacer()
        }
        
        HStack(alignment: .center) {
            
            VStack(alignment: .trailing, spacing: 12.0) {
                Text("Password Rotation Time:")
                Text("Auto Expiration Time:")
            }

            VStack(alignment: .leading, spacing: 7.0) {
                TextField("" , text: $passwordRotationTime, onEditingChanged: { (changed) in
                    passwordRotationTimeChanged = changed
                })
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: passwordRotationTime) { newValue in
                        if passwordRotationTimeChanged {
                            saveSettingsButtonDisabled = false
                        } else {
                            saveSettingsButtonDisabled = true
                        }
    //                    let defaults = UserDefaults.standard
    //                    defaults.set(jamfURL , forKey: "jamfURL")
                        //                    updateAction()
                    }
                    
                TextField("" , text: $autoExpirationTime, onEditingChanged: { (changed) in
                    autoExpirationTimeChanged = changed
                })
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: autoExpirationTime) { newValue in
                        if autoExpirationTimeChanged {
                            saveSettingsButtonDisabled = false
                        } else {
                            saveSettingsButtonDisabled = true
                        }
                    }
            }
        }
        .padding([.leading,.trailing])
        .alert(isPresented: self.$showAlert,
               content: {
            self.showCustomAlert()
        })

        HStack(alignment: .center) {
            Button("Fetch Settings") {
                Task {
                    await fetchSettings()

                }
            }
            Button("Save") {
                Task {
                    await saveSettings()
                }
            }
            .disabled(saveSettingsButtonDisabled)
        }

        //Get Password
        Divider()
        HStack {
            Text("Fetch Local Administration Password")
            Spacer()
        }
        .padding([.leading,.trailing, .bottom])
        HStack(alignment: .center) {
            
            VStack(alignment: .trailing, spacing: 12.0) {
                Text("Serial Number:")
                Text("Username:")
                Text("Password:")
            }

            VStack(alignment: .leading, spacing: 7.0) {
                TextField("" , text: $serialNumber)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: serialNumber) { newValue in

                        if !serialNumber.isEmpty && !lapsUserName.isEmpty {
                            fetchPassewordButtonDisabled = false
                        } else {
                            fetchPassewordButtonDisabled = true
                        }
                    }
                    
                TextField("" , text: $lapsUserName)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: lapsUserName) { newValue in
                        if !serialNumber.isEmpty && !lapsUserName.isEmpty {
                            fetchPassewordButtonDisabled = false
                        } else {
                            fetchPassewordButtonDisabled = true
                        }

                    }
                Text(lapsPassword)
                    .textSelection(.enabled)
            }
        }
        .padding([.leading,.trailing])
        HStack(alignment: .center) {
            Button("Fetch Password") {
                Task {
                    await fetchLAPSPassword()

                }
            }
            .disabled(fetchPassewordButtonDisabled)
        }


    }
    
    
    func showCustomAlert() -> Alert {
        return Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
                )
    }
    
    func fetchLAPSPassword() async {
        print("fetchLAPSPassword")
        
        let jamfPro = JamfProAPI(username: userName, password: password)
        let (authToken, _) = await jamfPro.getToken(jssURL: jamfURL, base64Credentials: jamfPro.base64Credentials)

        
        guard let authToken else {
            alertMessage = "Could not authenticate. Please check the url and authentication details"
            alertTitle = "Authentication Error"
            showAlert = true
            return
        }

        
        let (computerID, computerResponse) = await jamfPro.getComputerID(jssURL: jamfURL, authToken: authToken.token, serialNumber: serialNumber)
        
        print("Comoputer ID is \(computerID)")
        
        guard let computerID else {
            alertMessage = "Could not find this computer, please check the serial number."
            alertTitle = "Computer Record"
            showAlert = true
            return
        }

        let (managementID, managementIDResponse) = await jamfPro.getComputerManagementID(jssURL: jamfURL, authToken: authToken.token, id: computerID)
        
        print("managementID is \(managementID)")
        print("managementIDResponse is \(managementIDResponse)")
        guard let managementID else {
            alertMessage = "Could not retrieve the managementID, please check the serial number."
            alertTitle = "Management ID"
            showAlert = true
            return
        }
        
        let (password, passwordResponse) = await jamfPro.getLAPSPassword(jssURL: jamfURL, authToken: authToken.token, managementId: managementID, username: lapsUserName)
        
        guard let password else {
            alertMessage = "Could not retrieve the password, please check the serial number and laps user name."
            alertTitle = "Password"
            showAlert = true
            return
        }
        lapsPassword = password
        

    }
    
    func saveSettings() async {
        let jamfPro = JamfProAPI(username: userName, password: password)
        let (authToken, _) = await jamfPro.getToken(jssURL: jamfURL, base64Credentials: jamfPro.base64Credentials)

        guard let authToken else {
            alertMessage = "Could not authenticate. Please check the url and authentication details"
            alertTitle = "Authentication Error"
            showAlert = true
            return
        }
        
        guard let passwordRotationTimeInt = Int(passwordRotationTime) else {
            alertMessage = "The Password Rotation Time does not appear to be valid amount of seconds."
            alertTitle = "Password Rotation Time"
            showAlert = true
            return
        }
        
        guard let autoExpirationTimeInt = Int(autoExpirationTime) else {
            alertMessage = "The Auto Expiration Time does not appear to be valid amount of seconds."
            alertTitle = "Auto Expiration Time"
            showAlert = true
            return
        }


        let lapsSettings = LAPSSettings(autoDeployEnabled: autoDeployEnabled, passwordRotationTime: passwordRotationTimeInt, autoExpirationTime: autoExpirationTimeInt)
        
        let response = await jamfPro.saveSettings(jssURL: jamfURL, authToken: authToken.token, lapsSettings: lapsSettings)
        
        guard let response = response, response == 200 else {
            alertMessage = "Could not save LAPS settings. Error \(response)"
            alertTitle = "Save Error"
            showAlert = true
            return
        }
        
        saveSettingsButtonDisabled = true
        
    }

    
    func fetchSettings() async {


        passwordRotationTimeChanged = false
        autoExpirationTimeChanged = false
        enableLAPSChanged = false
        
        let jamfPro = JamfProAPI(username: userName, password: password)
        let (authToken, _) = await jamfPro.getToken(jssURL: jamfURL, base64Credentials: jamfPro.base64Credentials)

        
        
        guard let authToken else {
            alertMessage = "Could not authenticate. Please check the url and authentication details"
            alertTitle = "Authentication Error"
            showAlert = true
            return
        }
        let (lapsSettings, response) = await jamfPro.fetchSettings(jssURL: jamfURL, authToken: authToken.token)
       
        guard let response = response, response == 200 else {
            alertMessage = "Could not fetch LAPS settings. Error \(response)"
            alertTitle = "Fetch Error"
            showAlert = true
            return
        }

        if let lapsSettings = lapsSettings {
            if autoDeployEnabled != lapsSettings.autoDeployEnabled {
                enableLAPSChanged = true
            }
            autoDeployEnabled = lapsSettings.autoDeployEnabled
            passwordRotationTime = String(lapsSettings.passwordRotationTime)
            autoExpirationTime = String(lapsSettings.autoExpirationTime)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
