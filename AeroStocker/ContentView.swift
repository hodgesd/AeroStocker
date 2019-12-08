//
//  ContentView.swift
//  AeroStocker
//
//  Created by Derrick Hodges on 11/26/19.
//  Copyright © 2019 Derrick Hodges. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            StockViewer()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Stock")
            }
            
            AircraftViewer()
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("Aircraft")
            }
            
            ReferenceViewer()
                .tabItem {
                    Image(systemName: "book")
                    Text("Reference")
            }
            
            ShareViewer()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
            }
        }
    }
}

struct StockItem: Identifiable {
    var id: Int
    let name, category: String
}
struct StockItem2: Identifiable {
    var id : Int
    var standard, title, category, zone: String
    var needed :Int = 0
}

func update(_ stockItem2: inout StockItem2) {
    // Simply re-assigning the post to a new, mutable, variable
    // will actually create a new copy of it.
    stockItem2.needed += 3
}

struct Category: Identifiable {
    let id = UUID()
    let title: String
    let stockItems2: [StockItem2]
}

struct Zone: Identifiable {
    let id = UUID()
    let title: String
    let stockItems2: [StockItem2]
}

struct ItemData {
    // takes an array of StockItem2 objects and convert them into an array of Category objects
    var sections: [Category]
    var sectionsZones: [Zone]
    var stock: [StockItem2]
    
    init() {
        // create some stock items
        let first = StockItem2(id: 0, standard: "4", title: "Absolute", category: "Alcohol", zone: "Credenza", needed: 1)
        let second = StockItem2(id: 1, standard: "full", title: "Spoons", category: "Utinsil", zone: "Galley Left", needed: 2)
        let third = StockItem2(id: 2, standard: "6", title: "Coca Cola", category: "Beverage", zone: "Credenza", needed: 3)
        let fourth = StockItem2(id: 3, standard: "full", title: "Forks", category: "Utinsil", zone: "Galley Left", needed: 4)
        let fifth = StockItem2(id: 4, standard: "3", title: "Red Wine", category: "Alcohol", zone: "Credenza", needed: 0)

        // Create an array of the occurrence objects and then sort them
        // this makes sure that they are in ascending date order
        let items = [third, first, second, fourth, fifth]
            .sorted { $0.title < $1.title }

        // We use the Dictionary(grouping:) function so that all the events are
        // group together, one downside of this is that the Dictionary keys may
        // not be in order that we require, but we can fix that
        let grouped = Dictionary(grouping: items) { (stockitem2: StockItem2) -> String in
            stockitem2.category
        }
        
        let groupedZone = Dictionary(grouping: items) { (stockitem2: StockItem2) -> String in
            stockitem2.zone
        }
        

        // We now map over the dictionary and create our Day(Category) objects
        // making sure to sort them on the date of the first object in the occurrences array
        // You may want a protection for the date value but it would be
        // unlikely that the occurrences array would be empty (but you never know)
        // Then we want to sort them so that they are in the correct order
        self.sections = grouped.map { category -> Category in
            Category(title: category.key, stockItems2: category.value)
        }.sorted { $0.title < $1.title }
        self.sectionsZones = groupedZone.map { zone -> Zone in
            Zone(title: zone.key, stockItems2: zone.value)
        }.sorted { $0.title < $1.title}
        self.stock = items
    }
}


struct StockViewer : View {
    @State private var stockSorter: Int = 0

    let stockSorters = ["Type", "A - Z", "Zone"] // , "VIP", "Sensitive"
    let stockItems: [StockItem] = [
        .init(id: 0, name: "Chips", category: "Snacks"),
        .init(id: 1, name: "Sprite", category: "Soda"),
        .init(id: 2, name: "Forks", category: "Tableware")
    ]
    
    @State private var items = ItemData()
    
    fileprivate func groupByTypeView() -> List<Never, ForEach<[Category], UUID, Section<Text, ForEach<[StockItem2], Int, ItemRow>, EmptyView>>> {
        return //                List (stockItems, id: \.id) {stockItem in
            //                        Text (stockItem.name)
            //                }.listStyle(GroupedListStyle())
            //            }.navigationBarTitle(Text("Stock Items"))
            List {
                ForEach(items.sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.stockItems2) { stockItem2 in
                            ItemRow(item: stockItem2)
                            
                        }
                    }
                }
        }
    }
    fileprivate func listByName() -> List<Never, ForEach<[StockItem2], Int, ItemRow>> {
        return List {
            ForEach(items.stock) { stockItem2 in
                ItemRow(item: stockItem2)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                Picker("Stock Picker", selection: $stockSorter){
                    ForEach(0 ..< stockSorters.count) {
                        Text("\(self.stockSorters[$0])")
                    }
                }.pickerStyle(SegmentedPickerStyle())
                    .frame(width: 220.0)
                if stockSorter == 0 {
                    groupByTypeView()
                } else if stockSorter == 1 {
                    listByName()
                } else {
                    List {
                        ForEach(items.sectionsZones) { sectionsZones in
                            Section(header: Text(sectionsZones.title)) {

                                //                                without @state
                                ForEach(sectionsZones.stockItems2) { stockItem2 in
                                    ItemRow(item: stockItem2)
                                }

                                //                                with @state
                                //                                ForEach(sectionsZones.stockItems2, id: \.self, content: { stockItem2 in
                                //                                        ItemRow(item: stockItem2)
                                //                                }
                            }
                        }
                    }
                }
            }.navigationBarTitle(Text("Stock Items"))
        }
    }
}

struct ItemDetail: View {
    let item: StockItem2

    var body: some View {
        Text(item.title)
    }
}

struct ItemRow: View {
    @State private var numberOfItems: Int = 0
    //    @State private var checkState:Bool = false

    var item: StockItem2
    
    var body: some View {
        HStack(spacing: 10) {
       //     self.numberOfItems = item.needed
            Rectangle()
                .fill((self.numberOfItems > 0) ? Color.green : Color.red)
                .frame(width:20, height:20, alignment: .center)
                .cornerRadius(5)
            Text(item.title)
                .frame (width:80, alignment: .leading)
            Text("\(item.standard)")
                .foregroundColor(Color.gray)
                .frame(width:40, alignment: .center)
                .font(.subheadline)
            Spacer()
            //                 was working
//            Stepper(value: $numberOfItems, in: 0...10, label: { Text("\(numberOfItems)")
//            }).padding(.horizontal)
                        //                 trying working
            Stepper(value: $numberOfItems, in: 0...10){
                Text("\(numberOfItems)")
            }
        }
    }
}



struct AircraftViewer : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ReferenceViewer : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ShareViewer : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
