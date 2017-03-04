//
//  ScoreViewController.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 03/03/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    
    @IBOutlet weak var averageMarkLabel: UILabel!
    @IBOutlet weak var totalAsksLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var profileCompletionLabel: UILabel!
    @IBOutlet weak var totalHelpsLabel: UILabel!
    
    private var averageMark: Double!
    private var totalAsks: Double!
    private var totalHelps: Double!
    private var ratioHA: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initInfos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initInfos() {
        totalAsks = mainUser().getTotalAsks()
        totalHelps = mainUser().getTotalHelps()
        ratioHA = mainUser().getRationHA()
        averageMark = mainUser().getAverageMark()
        initLabels()
    }
    
    func initLabels() {
        totalAsksLabel.text = "Total asks sent: \(totalAsks!)"
        totalHelpsLabel.text = "Total helps completed: \(totalHelps!)"
        ratioLabel.text = "Ratio Help/Task: \(ratioHA!)"
        averageMarkLabel.text = "Average mark: \(averageMark!)"
    }

}
