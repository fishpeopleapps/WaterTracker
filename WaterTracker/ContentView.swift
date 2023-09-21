//
//  ContentView.swift
//  WaterTracker
//
//  Created by Kimberly Brewer on 9/19/23.
//
// TODO: i want it to fill up with a color not white...
// TODO: background isn't going to edge?
// TODO: metric units and goal should be in a settings pop-up on toolbar
// TODO: move some logic out
// Add Swiftlint
import SwiftUI

struct ContentView: View {
    @AppStorage("waterConsumed") private var waterConsumed = 0.0
    @AppStorage("waterRequired") private var waterRequired = 2000.0
    @AppStorage("useMetricUnits") private var useMetricUnits = false
    @AppStorage("lastDrink") private var lastDrink = Date.now.timeIntervalSinceReferenceDate
    let mlToOz = 0.0351951
    let ozToMl = 29.5735
    @State private var showingDrinksMenu = false
    var goalProgress: Double {
        waterConsumed / waterRequired
    }
    var statusText: Text {
        if useMetricUnits {
            return Text("\(Int(waterConsumed))ml / \(Int(waterRequired))ml")
        } else {
            let adjustedConsumed = waterConsumed * mlToOz
            let adjustedRequired = waterRequired * mlToOz
            return Text("\(Int(adjustedConsumed))oz / \(Int(adjustedRequired))oz")
        }
    }
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .cyan, .mint], startPoint: .bottom, endPoint: .top)
            
            VStack(spacing: 0) {
                statusText
                    .font(.largeTitle)
                    .padding(.top)
                    .padding(.bottom, 5)
                Image(systemName: "drop.fill")
                    .resizable()
                    .font(.title.weight(.ultraLight))
                    .scaledToFit()
                    .foregroundStyle(
                        .linearGradient(stops:
                                            [.init(color: .clear, location: 0),
                                             .init(color: .clear, location: 1 - goalProgress),
                                             .init(color: .white, location: 1 - goalProgress)]
                                        , startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        Image(systemName: "drop")
                            .resizable()
                            .font(.title.weight(.ultraLight))
                            .scaledToFit()
                    )
                    .onTapGesture {
                        showingDrinksMenu.toggle()
                    }
                VStack {
                    Text("Adjust Goal")
                        .font(.headline)
                    Slider(value: $waterRequired, in: 500...4000)
                        .tint(.white)
                    Toggle("Use Metric Units", isOn: $useMetricUnits)
                }
                .padding()
            }


        }
        .foregroundStyle(.white)
        .padding()
        .alert("Add Drink", isPresented: $showingDrinksMenu) {
            if useMetricUnits {
                ForEach([100, 200, 300, 400, 500], id: \.self) { number in
                    Button("\(number)ml") { add(Double(number))}
                }
            } else {
                ForEach([8, 12, 16, 24, 32], id: \.self) { number in
                    Button("\(number)oz") { add(Double(number) * ozToMl)}
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        // Allows us to check to see if a new day has started when the user makes the app active
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification),
            perform: checkForReset)
        // Allows us to reset once there's a new day (or a bunch of time has passed)
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.significantTimeChangeNotification),
            perform: checkForReset)
    }
    func add(_ amount: Double) {
        lastDrink = Date.now.timeIntervalSinceReferenceDate
        waterConsumed += amount
    }
    func checkForReset(_ notification: Notification) {
        let lastChecked = Date(timeIntervalSinceReferenceDate: lastDrink)
        if Calendar.current.isDateInToday(lastChecked) == false {
            waterConsumed = 0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
