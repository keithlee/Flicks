//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Keith Lee on 10/13/16.
//  Copyright © 2016 Keith Lee. All rights reserved.
//

import UIKit
import AFNetworking
import FTIndicator
import ReachabilitySwift

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var displayedMovies: [NSDictionary]?
    let posterUrlBase = "https://image.tmdb.org/t/p/w300"
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        let reachability = Reachability()!
        if reachability.isReachable {
            errorView.isHidden = true
        } else {
            errorView.isHidden = false
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        loadMovies(nil)
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadMovies(refreshControl.endRefreshing)
    }
    
    func loadMovies(_ callback: (() -> Void)?) {
        let apiKey = "6c4f30fcbc63f157eaed2f398dcfd8af"
        let urlString = "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)"
        let url = URL(string:urlString)
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        let reachability = Reachability()!
        if reachability.isReachable {
            errorView.isHidden = true
        } else {
            errorView.isHidden = false
        }
        FTIndicator.showProgressWithmessage("")
        
        let task : URLSessionDataTask = session.dataTask(with: request,
                   completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                        if let requestError = errorOrNil {
                            self.errorView.isHidden = false
                            print("Error with api request" + requestError.localizedDescription)
                            FTIndicator.dismissProgress()
                        } else {
                            if let data = dataOrNil {
                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                    with: data, options:[]) as? NSDictionary {
                                    
                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                    if self.searchBar.text != "" {
                                        self.displayedMovies = self.filteredMovies(self.searchBar.text!)
                                    } else {
                                        self.displayedMovies = self.movies
                                    }
                                    FTIndicator.dismissProgress()
                                    self.tableView.reloadData()
                                    callback?()
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
        if let movies = displayedMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        if let movies = displayedMovies {
            let data = movies[indexPath.row] as NSDictionary
            cell.titleLabel.text = data["title"] as? String
            
            if let poster_path = data["poster_path"] as? String {
                let posterUrl = URL(string: posterUrlBase + poster_path)
                let urlRequest = URLRequest(url: posterUrl!)
                cell.posterView.setImageWith(urlRequest, placeholderImage: nil,
                    success: { (urlRequest, imageResponse, image) in
                        // imageResponse will be nil if the image is cached
                        if imageResponse != nil {
                            cell.posterView.alpha = 0.0
                            cell.posterView.image = image
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                cell.posterView.alpha = 1.0
                            })
                        } else {
                            cell.posterView.image = image
                        }
                    },
                    failure: { (urlRequest, imageResponse, error) in
                        print(error)
                    }
                )
            }
            cell.descriptionLabel.text = data["overview"] as? String
            cell.descriptionLabel.sizeToFit()
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.cyan
            cell.selectedBackgroundView = backgroundView
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            displayedMovies = movies
            searchBar.resignFirstResponder()
            searchBar.performSelector(onMainThread: #selector(resignFirstResponder), with: nil, waitUntilDone: false)
        } else {
            displayedMovies = filteredMovies(searchText)
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filteredMovies(_ text: String) -> [NSDictionary]? {
        return movies?.filter {
            let title = $0["title"] as? String
            if title!.lowercased().contains(text.lowercased()) {
               return true
            } else {
                return false
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let movieCell = sender as! MovieCell
        let indexPath = tableView.indexPath(for: movieCell)
        let movie = displayedMovies?[indexPath!.row]
        movieCell.isSelected = false
        
        let vc = segue.destination as! DetailViewController
        vc.movie = movie
        
    }

}
