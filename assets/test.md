# Lesson: Proxy Pattern

## Team: Syntax Error 
- Mikhaella Jing Carumbana
- Jomar Magdalaga
- Karl John Villardar

## History of the Proxy Pattern
The Proxy pattern is a well-known design pattern in software engineering. Its origins can be traced back to the "Design Patterns: Elements of Reusable Object-Oriented Software" book, commonly referred to as the "Gang of Four" (GoF) book. The authors of this influential book - Erich Gamma, Richard Helm, Ralph Johnson, and John Vlissides, collectively known as the Gang of Four - documented the Proxy pattern in their book, first published in 1994.

## Definition of Proxy Pattern
In general, a proxy signifies acting on behalf of something or someone else, often serving as a representative or stand-in. The Proxy pattern directly applies this concept in software development. Proxies can be referred to as surrogates, handles, or wrappers, although they have different structures and purposes from Adapters and Decorators.

## Types of Proxies
1. Remote Proxy
   - A remote proxy acts as a local representative for an object located in a different address space. It handles communication between the client and the actual object, which may be present on a remote server.
2. Virtual Proxy
   - A virtual proxy provides a placeholder for an expensive resource and delays its creation until it is actually needed. It allows the client to use the proxy object initially, and the actual object is instantiated only when necessary.
3. Protection Proxy
   - A protection proxy controls access to the original object by enforcing an additional layer of security or providing authentication mechanisms. It ensures that only authorized clients can access the object.
4. Smart Proxy
   - A smart proxy performs additional tasks before or after accessing the actual object. It may be responsible for caching results, logging, or other optimizations.

## Usage of Proxy Pattern
The Proxy pattern is used when there is a need to create a wrapper that hides the complexity of the main object from the client. This allows the client to interact with the proxy object instead of directly accessing the main object. This can be useful in scenarios where the main object is resource-intensive or requires additional security measures.

To learn more about the Proxy pattern, you can refer to the following resources:
- [Adapter Pattern](https://www.geeksforgeeks.org/adapter-pattern/)
- [Decorator Pattern](https://www.geeksforgeeks.org/the-decorator-pattern-set-2-introduction-and-design/)

That concludes our lesson on the Proxy pattern. Thank you for learning with us!