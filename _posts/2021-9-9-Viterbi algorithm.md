---
layout: post
title: A simple illustration of Viterbi algorithm
---

This blog will illustrate Viterbi algorithm in a more “nature language way” without any complicated equation. Even if you don’t have background in language processing, you could still read till end. 

When we see a **sequence labeling problem** as a classification problem in label space, the label space is exponentially large, for example, if we have a sentence length of 20, tag set size is 10, then we have 10^20 possible tagged sequences, because in each position of this sentence, you will have 10 possible tags. It is impossible for us to choose one by one. So how do we deal with it? We make restrictions as a bigram language model over tags, considers “pairs” once upon a time and decomposes it into local parts and then sum them up. Viterbi algorithm is uses **dynamic programming** to find the best inference result.

If you want to directly see an example, you could jump to the Example part, but I suggest if you have time, please read and check the reason why it works that way.

## 1. Definition of Concepts:

Some simple definitions of concepts are required for later representation.
**Emission features** are word-tag pairs, means “the weight this word should have this tag”, **transition features** are tag-tag pairs, means “the weight the second tag following the first tag”. We can write the value of each feature function to the sum of value of emission feature and value of transition feature. 

**Viterbi variable** is created to represent the score of the best tag sequence ending in current tag in current position, in the example part, it is the number in the red node in the graph.

## 2. The heart of Viterbi algorithm
What we want to do is maximum the whole weight of the tagged sentence. And this becomes a dynamic programming problem.

![](https://raw.githubusercontent.com/wjrforcyber/wjrforcyber.github.io/master/images/20210909_Viterbi_algorithm/Graph1.JPG)

Graph 1 shows why it is a dynamic programming problem, generally speaking, we want the value of a (the weights sum of the whole sentence) as big as possible, and when we separate out the word M, this becomes a problem of sum of the maximum b and maximum weight of M (has a specific tag), iteratively, this becomes the maximum of the word 1 (has a specific tag). So, in this way we are dealing with an “auxiliary problem” to solve the original problem. And it is easier to solve the problem when you add a Start and End state.


## 3. Example:

I will use the example *“they can fish”* from Jacob Eisenstein’s Nature Language Processing book to illustrate how to compute it by hand step by step:

1). First of all, you should have weights for each emission feature and transition feature, in Table 7.1 are the weights we’ll going to use to calculate the Viterbi variable.

<div align=center>
<img src="https://raw.githubusercontent.com/wjrforcyber/wjrforcyber.github.io/master/images/20210909_Viterbi_algorithm/VA.JPG" width="900"/>
</div>


2). Step by step calculation and illustration:
(This structure has a particular name called **“trellis”**. Red one is what we selected)

<div align=center>
<img src="https://raw.githubusercontent.com/wjrforcyber/wjrforcyber.github.io/master/images/20210909_Viterbi_algorithm/1.JPG" width="660"/>
</div>

<div align=center>
<img src="https://raw.githubusercontent.com/wjrforcyber/wjrforcyber.github.io/master/images/20210909_Viterbi_algorithm/2.JPG" width="660"/>
</div>

<div align=center>
<img src="https://raw.githubusercontent.com/wjrforcyber/wjrforcyber.github.io/master/images/20210909_Viterbi_algorithm/3.JPG" width="660"/>
</div>

<div align=center>
<img src="https://raw.githubusercontent.com/wjrforcyber/wjrforcyber.github.io/master/images/20210909_Viterbi_algorithm/4.JPG" width="660"/>
</div>

<div align=center>
<img src="https://raw.githubusercontent.com/wjrforcyber/wjrforcyber.github.io/master/images/20210909_Viterbi_algorithm/5.JPG" width="660"/>
</div>

The result for the sequence is obvious in this situation, “they can fish” tagged as ”N V N”. However, we should remember sometimes words may have other meanings, for this specific sequence, “fish” can also be a “V” which does make sense.


After reading this blog, you could manually do the calculation if you want, sometimes optimization problem in ML/DL people use minimum to decide the best solution, we use maximum so all weights are negative, any choice is good to go.

