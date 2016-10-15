//
//  DetailViewController.swift
//  Flicks
//
//  Created by Keith Lee on 10/14/16.
//  Copyright © 2016 Keith Lee. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController {
    
    var movie: NSDictionary!
    let posterUrlBase = "https://image.tmdb.org/t/p/w300"
    @IBOutlet weak var posterView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: infoView.frame.origin.y + 336)
        
        titleLabel.text = movie["title"] as? String
        overviewLabel.text = movie["overview"] as? String
        if let backdrop_path = movie["backdrop_path"] as? String {
            let posterUrl = URL(string: posterUrlBase + backdrop_path)
            posterView.setImageWith(posterUrl!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
