//
//  TaskDetailViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 28/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    
    @IBOutlet weak var taskTypeLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    
    var detailTask: asksArround? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        if let detailTask = detailTask {
            if let typeLabel = taskTypeLabel, let dateLabel = taskDateLabel {
                typeLabel.text = detailTask.type
                dateLabel.text = detailTask.date
            }
        }
    }

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
