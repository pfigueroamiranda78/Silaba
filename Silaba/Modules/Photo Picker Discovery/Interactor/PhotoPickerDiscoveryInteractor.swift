class PhotoPickerDiscoveryInteractor: PhotoPickerDiscoveryInteractorInterface {
    
    weak var output: PhotoPickerDiscoveryInteractorOutput?
    var service: TalentService!
    
    required init(service: TalentService) {
        self.service = service
    }
}

extension PhotoPickerDiscoveryInteractor: PhotoPickerDiscoveryInteractorInput {
    
    
    func fetchTalentAll() {
        service.fetchTalentAll() { (talentResult) in
            self.output?.photoPickerDiscoveryDidFetchTalent(with: talentResult)
        }
    }
    
}
