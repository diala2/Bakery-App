//
//  BakeryViewController.swift
//  Bakery App
//
//  Created by Diala Abdulnasser Fayoumi on 21/07/1446 AH.
//

import UIKit

class BakeryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewModel = BakeryViewModel()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchData()
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func fetchData() {
        viewModel.fetchChefs()
            self.tableView.reloadData() // Reload data after fetching chefs
        
        viewModel.fetchUsers()
            self.tableView.reloadData() // Reload data after fetching users
        
        viewModel.fetchCourses()
            self.tableView.reloadData() // Reload data after fetching courses
        
        let userId = "someUserId" // Replace with the actual user ID
        viewModel.fetchBookings()
        
         self.tableView.reloadData() // Reload data after fetching bookings
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Chefs, Users, Courses, Bookings
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.chefs.count
        case 1: return viewModel.users.count
        case 2: return viewModel.courses.count
        case 3: return viewModel.bookings.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = viewModel.chefs[indexPath.row].name // Access chef's name
        case 1:
            cell.textLabel?.text = viewModel.users[indexPath.row].name
        case 2:
            cell.textLabel?.text = viewModel.courses[indexPath.row].title
        case 3:
            cell.textLabel?.text = "Booking for user: \(viewModel.bookings[indexPath.row].userId)"
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Chefs"
        case 1: return "Users"
        case 2: return "Courses"
        case 3: return "Bookings"
        default: return nil
        }
    }
}
