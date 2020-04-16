//  ContentView.swift
//  Contacts-Diffable-SwiftUI
//  Created by George Garcia on 4/15/20.
//  Copyright © 2020 GeeTeam. All rights reserved.

import SwiftUI

enum SectionType {
    case yourself, family, closeFriends, friends
}

struct Contact: Hashable {
    let name: String
    var isFavorite = false
}

class ContactViewModel: ObservableObject { // whenever the view model changes, line 24 block will update itself
    @Published var name = ""
    @Published var isFavorite = false
}

struct ContactRowView: View { // here we can create the cell where we can add UIImage etc
    
    @ObservedObject var viewModel: ContactViewModel
    
    var body: some View {
        
        HStack {
            Image(systemName: "person.fill")
            Text(viewModel.name)
            Spacer()
            Image(systemName: "star")
        }.padding(20)
    }
}

// Creating a custom Cell
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

class DiffableTableViewController: UITableViewController {
    
    lazy var source: UITableViewDiffableDataSource<SectionType, Contact> = .init(tableView: self.tableView) { (_, indexPath, contact) -> UITableViewCell? in
        
        let cell = ContactCell(style: .default, reuseIdentifier: nil)
        cell.viewModel.name = contact.name
        return cell
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
            label.text = "Yourself"
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
        Text("Yo")
    }
}
