class TestimonialsController < ApplicationController
  def index
    @students = [
      {
        text: "This book couldn't have been more insightful or more relevant. I loved the characters, the writing, the plot, and the ideas. Honestly, if everyone in America could read and fully comprehend this book I'm convinced that our debt crisis would disappear. Thank you for providing me the chance to be introduced to such a work of genius.",
        name: "Kristen Hansen",
        attribution: "studying political science at Brigham Young University, after reading",
        book: "Atlas Shrugged",
      },
      {
        text: "It was a life changing series of essays that really opened my eyes to the philosophy of Objectivism.",
        name: "Zack",
        attribution: "studying electrical engineering at ITT, after reading",
        book: "The Virtue of Selfishness",
      },
      {
        text: "Ayn Rand comes up a lot in intelligent conversation, and I want to read at least one thing so I know what people are talking about. In the process, I'll read a potentially life-changing book.",
        name: "Justin Walters",
        attribution: "studying business at Sterling HS in Somerdale, NJ, who wants to read",
        book: "Atlas Shrugged",
      },
      {
        text: "I am interested in Rand's ideas about ideal behavior and I want to understand why she thinks individuals should work towards their own happiness, not for the success of a group.",
        name: "Savannah Steele",
        attribution: "studying studio art in Minneapolis, MN, who wants to read",
        book: "Atlas Shrugged",
      },
      {
        text: "As a young student in Canada I'm constantly bombarded with socialist ideas from peers my age. People just don't seem to understand the advantages to a capitalist system. ... I think reading this book would help me be a better free thinker, and that in itself is a priceless gift. In my future as a filmmaker I want to make films that promote freedom, capitalism, and personal liberty. The more I can the learn the better message I can send!",
        name: "Sam Coleman",
        attribution: "studying Screen Arts at NSCC in Canada, who wants to read",
        book: "Atlas Shrugged",
      },
    ]

    @donors = [
      {
        text: "Ayn Rand has given me the tools to build a life far beyond any dreams I had as a teen. It is a privilege to be able to help another mind to discover what Rand wrote and understand why she still affects me on a daily basis 42 years after I first read her.",
        name: "Doug Vail",
        attribution: "Texas",
      },
      {
        text: "Reading Ayn Rand's books has been a life altering experience for me. Through this website many more will live through that experience.",
        name: "Arshak and Armen Benlian",
        attribution: "Bronxville, NY",
      },
    ]
  end
end