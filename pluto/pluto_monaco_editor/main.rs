use std::collections::HashMap;

fn main(){
    let teams = vec![String::from("Blue"), String::from("Yellow")];
    let initial_scores = vec![10, 50];
    let scores: HashMap<_, _> = 
        teams.into_iter().zip(initial_scores.into_iter()).collect();

    println!("{:?}", scores);


    let a = [1,2,3];
    let doubled: Vec<i32> = a.iter().map(|&x| x * 2).collect();
    println!("{:?}", doubled);
}
