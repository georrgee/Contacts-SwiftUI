//  ContentView.swift
//  Contacts-Diffable-SwiftUI
//  Created by George Garcia on 4/15/20.
//  Copyright © 2020 GeeTeam. All rights reserved.

import SwiftUI

enum SectionType {
    case yourself, family, closeFriends, friends
}

class Contact: NSObject {
    let name: String
    var isFavorite = false
    
    init(name: String) {
        self.name = name
    }
}

class ContactViewModel: ObservableObject {
    @Published var name = ""
    @Published var isFavorite = false
}

struct ContactRowView: View {
    
    @ObservedObject var viewModel: ContactViewModel
    
    var body: some View {
        
        HStack (spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 34))
            Text(viewModel.name)
            Spacer()
            Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                .font(.system(size: 24))
        }.padding(20)
    }
}

class ContactCell: UITableViewCell {
    
    let viewModel = ContactViewModel()
    lazy var row  = ContactRowView(viewModel: viewModel)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // setup SWIFTUI...
        let hostingController = UIHostingController(rootView: row)
        addSubview(hostingController.view)
        hostingController.view.fillSuperview()
        
        viewModel.name = "Test"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ContactsSource: UITableViewDiffableDataSource<SectionType, Contact> {
    // subclass Diffable data source in order to do the swipe action
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

class DiffableTableViewController: UITableViewController {
    
    lazy var source: ContactsSource = .init(tableView: self.tableView) { (_, indexPath, contact) -> UITableViewCell? in
        
        let cell = ContactCell(style: .default, reuseIdentifier: nil)
        cell.viewModel.name = contact.name
        cell.viewModel.isFavorite = contact.isFavorite
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            completion(true)
            
            var snapshot = self.source.snapshot()
            // figure out the contact we need to delete
            guard let contact = self.source.itemIdentifier(for: indexPath) else { return }
            snapshot.deleteItems([contact])
            self.source.apply(snapshot)
        }
        
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { (_, _, completion) in
            completion(true)
            
            // super tricky part... how to reload a cell inside a diffable data source...
            var snapshot = self.source.snapshot()
            guard let contact = self.source.itemIdentifier(for: indexPath) else { return }
            contact.isFavorite.toggle()
            snapshot.reloadItems([contact])
            self.source.apply(snapshot)
            
        }
        
        return .init(actions: [deleteAction, favoriteAction])
    }
    
    private func setupSource() {
        var snapshot = source.snapshot() //
        snapshot.appendSections([.yourself, .family, .closeFriends, .friends])
        
        snapshot.appendItems(
            [.init(name: "George"),
        ], toSection: .yourself)

        snapshot.appendItems(
            [.init(name: "Mom"),
             .init(name: "Dad"),
             .init(name: "Lil Bro")
        ], toSection: .family)
        
        snapshot.appendItems(
            [.init(name: "Kevin"),
             .init(name: "Checko"),
             .init(name: "Rey"),
             .init(name: "Stephen")
        ], toSection: .closeFriends)
        
        snapshot.appendItems(
            [.init(name: "Tien"),
             .init(name: "Greg"),
             .init(name: "Anna"),
             .init(name: "CJ"),
        ], toSection: .friends)
        
        source.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        
        switch section {
        case 0:
            label.text = "You"
        case 1:
            label.text = "Family"
        case 2:
            label.text = "Close Friends"
        case 3:
            label.text = "Friends"
        default:
            label.text = "N/A"
        }
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSource()
    }
}

struct DiffiableContainer: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: DiffableTableViewController(style: .insetGrouped))
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    typealias UIViewControllerType = UIViewController
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiffiableContainer()
    }
}

struct ContentView: View {
    var body: some View {
        Text("")
    }
}
