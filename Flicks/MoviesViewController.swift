//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Keith Lee on 10/13/16.
//  Copyright © 2016 Keith Lee. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    let posterUrlBase = "https://image.tmdb.org/t/p/w300"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        
        
        let apiKey = "6c4f30fcbc63f157eaed2f398dcfd8af"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,
                   completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                        if let requestError = errorOrNil {
                            print("Error with api request" + requestError.localizedDescription)
                        } else {
                            if let data = dataOrNil {
                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                    with: data, options:[]) as? NSDictionary {
                                    
                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                    self.tableView.reloadData()
                                }
                            }
                        }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        if let movies = movies {
            let data = movies[indexPath.row] as NSDictionary
            cell.titleLabel.text = data["title"] as? String
            if let backdrop_path = data["backdrop_path"] as? String {
                let posterUrl = URL(string: posterUrlBase + backdrop_path)
                cell.posterView.setImageWith(posterUrl!)
            }
            cell.descriptionLabel.text = data["overview"] as? String
            cell.descriptionLabel.sizeToFit()
        }
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let movieCell = sender as! MovieCell
        let indexPath = tableView.indexPath(for: movieCell)
        let movie = movies?[indexPath!.row]
        
        let vc = segue.destination as! DetailViewController
        vc.movie = movie
        
    }

}
