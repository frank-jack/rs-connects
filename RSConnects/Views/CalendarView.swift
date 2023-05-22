//
//  CalendarView.swift
//  RSConnects
//
//  Created by Jack Frank on 5/22/23.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var modelData: ModelData
    var body: some View {
        NavigationStack {
            VStack {
                WebView(url: URL(string: "https://rodephshalom.org/calendar/")!)
                    .onAppear {
                        var getRequest = URLRequest(url: URL(string: "https://rodephshalom.org/wp-json/tribe/events/v1/events/")!)
                        getRequest.httpMethod = "GET"
                        getRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        let getSession = URLSession.shared
                        let getTask = getSession.dataTask(with: getRequest, completionHandler: { data, response, error -> Void in
                            print(response!)
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                                print("TEC data start")
                                print(json)
                                print("TEC data end")
                                print(json["events"]?.count)
                            } catch {
                                print("error")
                            }
                        })
                        getTask.resume()
                    }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
