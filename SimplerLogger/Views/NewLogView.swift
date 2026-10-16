//
//  NewLogView.swift
//  SimplerLogger
//
//  Created by David Rynn on 6/8/22.
//

import CoreData
import SwiftUI

struct NewLogView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @State var name: String = ""
    @State var useIntervals = false
    @State var error: Error? = nil
    @State var hasError = false
    let defaultPadding = 10.0
    
    var body: some View {
            Form {
                if error != nil {
                    Text("Error: \(error.debugDescription)")
                }
                Section(header: Text("Start and stop over an interval of time for an entry?") ) {
                    Toggle("Use Intervals", isOn: $useIntervals)
                        .padding(defaultPadding)
                }
                Section(header: Text("Log Name")) {
                    TextField(!name.isEmpty ? name : "Please enter name here.", text: $name) {
                        done()
                    }
                }
            }
            .navigationBarItems(leading: Button(action: { dismiss() }, label:{ Text("Cancel") }), trailing: Button(action: {
                done()
            }, label: { Text("Done") }))
    }
    
    func done() {
        guard !name.isEmpty else {
            dismiss()
            return
        }
        addNewLog()

    }
    
    func addNewLog() {
        let newLog = dataController.createNewLog(name)
        newLog.usesIntervals = useIntervals
        save()
    }
    
    func save() {
        do {
            try moc.save()
            dismiss()
        } catch {
            self.error = LogError.CoreDataError.save
            return
        }
    }
}

struct AddLogView_Previews: PreviewProvider {
    static var previews: some View {
        NewLogView()
    }
}
