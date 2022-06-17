//
//  UpdateLogView.swift
//  SimpleLogger
//
//  Created by David Rynn on 6/9/22.
//

import SwiftUI

struct UpdateLogView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @Binding var name: String
    @Binding var useIntervals: Bool
    let defaultPadding = 10.0
    
    var body: some View {
        
        Form {
            Section(header: Text("Start and stop over an interval of time for an entry?") ) {
                Toggle("Use Intervals", isOn: $useIntervals)
                    .padding(defaultPadding)
            }
            Section(header: Text("Log Name")) {
                TextField(name, text: $name) {
                    done()
                }
            }
        }
        .navigationBarItems(trailing: Button(action: {
            done()
        }, label: { Text("Done") }))
        
    }
    
    func done() {
       dismiss()
    }

}

//struct UpdateLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        UpdateLogView()
//    }
//}
