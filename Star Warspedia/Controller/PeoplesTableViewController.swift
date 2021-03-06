//
//  PeoplesTableViewController.swift
//  Star Warspedia
//
//  Created by Tanveer Bashir on 6/18/17.
//  Copyright © 2017 Tanveer Bashir. All rights reserved.
//

import UIKit

private let maxPageNumber = 9

class PeoplesTableViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.register(ReusableCell.nib, forCellReuseIdentifier: ReusableCell.id)
        }
    }

    private var peoples: [People] = []
    private var page: Int = startPageNumber

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchPeoples()
        self.title = "PEOPLES"
    }

    private func fetchPeoples() {
        Progress.show
        SWAPI.requestPeople(from: .people(page)) { [unowned self] peoples in
            self.sendToMainQueue(peoples)
        }
    }

    private func loadMoreData() {
        if page < maxPageNumber {
            page += startPageNumber
            SWAPI.requestPeople(from: .people(page)) { peoples in
                self.peoples += peoples
                OperationQueue.main.addOperation { [ unowned self] in
                    self.tableView.reloadData()
                }
            }
        } else {
            Message.loadError(in: (String(describing: type(of: self))))
        }
    }

    private func sendToMainQueue(_ data: [People]) {
        DispatchQueue.main.async {  [unowned self] in
            self.peoples = data
            self.tableView.reloadData()
            Progress.dismiss
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PeopleDetailViewController" {
            if let dvc = segue.destination as? PeopleDetailViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    dvc.people = peoples[indexPath.row]
                }
            }
        }
    }
}

extension PeoplesTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peoples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCell.id, for: indexPath) as! ReusableCell
        cell.name = peoples[indexPath.row].name
        return cell
    }
}

extension PeoplesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = peoples.count-1
        if indexPath.row == lastElement {
            loadMoreData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PeopleDetailViewController", sender: nil)
    }
}
