//
//  LogDetailsView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/29/22.
//

import SwiftUI

struct EntryDetailsView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @ObservedObject var entry: EntryEntity
    var showStopDate: Bool {
        return stopDate != nil
    }
    @State var startDate: Date
    @State var stopDate: Date?
    @State var error: Error?
    @State var note: String
    let formatter: DateFormatter
    let componentsFormatter: DateComponentsFormatter
    
    init(entry: EntryEntity) {
        self.entry = entry
//        _entry = State(initialValue: entry)
        _startDate = State(initialValue: entry.start ?? Date())
        _stopDate = State(initialValue: entry.end)
        _note = State(initialValue: entry.note ?? "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        self.formatter = dateFormatter
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.unitsStyle = .abbreviated
        self.componentsFormatter = componentsFormatter
    }
    
    var body: some View {
        List {
            VStack{
                if error != nil {
                    Text("Error: \(error.debugDescription)")
                        .foregroundColor(.red)
                }
                DatePicker(selection: $startDate, in: ...Date(), displayedComponents: [ .date, .hourAndMinute]) {
                    Text("Edit")
                }
                Text("Start time: \(startDate, formatter: formatter)")
                if stopDate != nil {
                    Text(componentsFormatter.getDurationStrings(startDate, end: stopDate.bound) ?? "Error: \(LogError.InvalidDate.componentFormatter)")
                    
                    DatePicker(selection: $stopDate.bound, in: ...Date(), displayedComponents: [.date, .hourAndMinute]) {
                        Text("Edit")
                    }
                    Text("Stop time: \(formatter.string(from: stopDate.bound))")
                }
                TextField("Note", text: $note) {
                    entry.note = note
                    save()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                    Button {
                        save()
                        dismiss()
                    } label: {
                        Text("done")
                    }
                }
            }
        }
        
    }
    
    func save() {
        entry.start = startDate
        entry.end = stopDate
        do {
            try moc.save()
            self.error = nil
        } catch {
            self.error = error
        }
    }
}

//struct EntryDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        EntryDetailsView(entry: <#EntryEntity#>)
//    }
//}
extension Optional where Wrapped == Date {
    var _bound: Date? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: Date {
        get {
            return _bound ?? Date()
        }
        set {
            _bound = newValue
        }
    }
}
