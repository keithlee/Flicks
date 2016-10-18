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
    let smallPosterUrlBase = "https://image.tmdb.org/t/p/w300"
    let largePosterUrlBase = "https://image.tmdb.org/t/p/original"
    @IBOutlet weak var posterView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if Reachability.isConnectedToNetwork() {
            errorView.isHidden = true
        } else {
            errorView.isHidden = false
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: infoView.frame.origin.y + 336)
        
        titleLabel.text = movie["title"] as? String
        self.navigationItem.title = movie["title"] as? String
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        if let poster_path = movie["poster_path"] as? String {
            let smallPosterUrl = URL(string: smallPosterUrlBase + poster_path)
            let urlRequest = URLRequest(url: smallPosterUrl!)
            posterView.setImageWith(urlRequest, placeholderImage: nil,
                success: { (urlRequest, imageResponse, image) in
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        self.posterView.alpha = 0.0
                        self.posterView.image = image
                        
                        UIView.animate(
                            withDuration: 1,
                            animations: {
                                self.posterView.alpha = 1
                            },
                            completion: { (success) in
                                self.setLargeImage(poster_path: poster_path)
                            }
                        )
                    } else {
                        UIView.animate(
                            withDuration: 1,
                            animations: {
                                self.posterView.image = image
                            },
                            completion: { (success) in
                                self.setLargeImage(poster_path: poster_path)
                            }
                        )
                    }
                },
                failure: { (urlRequest, imageResponse, error) in
                    print(error.localizedDescription)
                }
            )
        }
    }
    
    func setLargeImage(poster_path: String) {
        let largeUrlRequest = URLRequest(url: URL(string: self.largePosterUrlBase + poster_path)!)
        self.posterView.setImageWith(
            largeUrlRequest,
            placeholderImage: nil,
            success: { (largeImageRequest, response, largeImage) in
                self.posterView.image = largeImage
            },
            failure: { (request, response, error) in
                print(error.localizedDescription)
            }
        )
        
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
