Generate video mosaic previews.

### Installation

```
make install
```

### Usage

```
genThumbs [videos]
```

### Docker

```
make build

docker run -v "$(pwd)":/home/ genthumbs [videos]
```

### Dependencies
 - `ffmpeg`
 - `ffprobe`
 - `bc`
 
 ### Examples

 ![BigBuckBunny](/assets/BigBuckBunny.png)
 ![owarimonogatari](/assets/owarimonogatari.png)
 ![bonobo](/assets/bonobo.png)
